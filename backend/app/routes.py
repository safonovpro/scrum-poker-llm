import uuid
from datetime import datetime
from flask import Blueprint, request, jsonify
from . import db, socketio
from .models import Room, Player, Round, Vote, Role

bp = Blueprint('routes', __name__)


# ==================== Rooms ====================

@bp.route('/rooms', methods=['POST'])
def create_room():
    """Создать новую комнату"""
    data = request.get_json()
    
    name = data.get('name')
    host_nickname = data.get('host_nickname')
    
    if not name or not host_nickname:
        return jsonify({'error': 'Name and host_nickname are required'}), 400
    
    room = Room(
        id=str(uuid.uuid4()),
        name=name
    )
    db.session.add(room)
    db.session.flush()  # Получить ID для создания игрока
    
    # Создаем ведущего комнаты
    host = Player(
        id=str(uuid.uuid4()),
        room_id=room.id,
        nickname=host_nickname,
        role=Role.HOST
    )
    db.session.add(host)
    db.session.commit()
    
    # Отправляем событие WebSocket
    socketio.emit('room_created', {
        'room_id': room.id,
        'room_name': room.name,
        'host_id': host.id,
        'host_nickname': host_nickname
    }, room=room.id)
    
    return jsonify({
        'room_id': room.id,
        'room_name': room.name,
        'host_id': host.id,
        'invite_url': f"/join/{room.id}"
    }), 201


@bp.route('/rooms/<room_id>', methods=['GET'])
def get_room(room_id):
    """Получить информацию о комнате"""
    room = Room.query.get(room_id)
    
    if not room:
        return jsonify({'error': 'Room not found'}), 404
    
    players = [
        {
            'id': p.id,
            'nickname': p.nickname,
            'role': p.role.value,
            'is_ready': p.is_ready
        }
        for p in room.players
    ]
    
    rounds_data = []
    for round in room.rounds.order_by(Round.id.desc()).limit(10):
        votes = [
            {'player_id': v.player_id, 'voted': v.value is not None}
            for v in round.votes
        ]
        rounds_data.append({
            'id': round.id,
            'task_description': round.task_description,
            'started_at': round.started_at.isoformat(),
            'revealed_at': round.revealed_at.isoformat() if round.revealed_at else None,
            'is_active': round.is_active,
            'votes': votes
        })
    
    return jsonify({
        'id': room.id,
        'name': room.name,
        'created_at': room.created_at.isoformat(),
        'is_active': room.is_active,
        'players': players,
        'recent_rounds': rounds_data
    })


@bp.route('/rooms/<room_id>/join', methods=['POST'])
def join_room(room_id):
    """Присоединиться к комнате"""
    room = Room.query.get(room_id)
    
    if not room:
        return jsonify({'error': 'Room not found'}), 404
    
    data = request.get_json()
    nickname = data.get('nickname')
    role = data.get('role', 'player')  # 'player' или 'observer'
    
    if not nickname:
        return jsonify({'error': 'Nickname is required'}), 400
    
    if role not in ['player', 'observer']:
        return jsonify({'error': 'Invalid role'}), 400
    
    player = Player(
        id=str(uuid.uuid4()),
        room_id=room.id,
        nickname=nickname,
        role=Role(role)
    )
    db.session.add(player)
    db.session.commit()
    
    # Отправляем событие WebSocket
    socketio.emit('player_joined', {
        'player_id': player.id,
        'nickname': nickname,
        'role': role
    }, room=room.id)
    
    return jsonify({
        'player_id': player.id,
        'nickname': nickname,
        'role': role
    }), 201


# ==================== Rounds ====================

@bp.route('/rooms/<room_id>/rounds', methods=['POST'])
def start_round(room_id):
    """Начать новый раунд (только ведущий)"""
    room = Room.query.get(room_id)
    
    if not room:
        return jsonify({'error': 'Room not found'}), 404
    
    data = request.get_json() or {}
    task_description = data.get('task_description')
    host_id = data.get('host_id')
    
    # Проверка что запрашивающий - ведущий
    host = Player.query.filter_by(room_id=room_id, role=Role.HOST).first()
    if not host or host.id != host_id:
        return jsonify({'error': 'Only host can start rounds'}), 403
    
    # Завершаем предыдущие активные раунды
    for round in room.rounds.filter_by(is_active=True).all():
        round.is_active = False
    
    # Создаём новый раунд
    round = Round(
        room_id=room.id,
        task_description=task_description,
        is_active=True
    )
    db.session.add(round)
    db.session.commit()
    
    # Создаём записи для голосов всех игроков-участников
    for player in room.players.filter(Player.role != Role.OBSERVER).all():
        vote = Vote(round_id=round.id, player_id=player.id, value=None)
        db.session.add(vote)
    db.session.commit()
    
    # Отправляем событие WebSocket
    socketio.emit('round_started', {
        'round_id': round.id,
        'task_description': task_description,
        'players': [
            {'id': p.id, 'nickname': p.nickname}
            for p in room.players.filter(Player.role != Role.OBSERVER).all()
        ]
    }, room=room.id)
    
    return jsonify({
        'round_id': round.id,
        'task_description': task_description
    }), 201


# ==================== Votes ====================

@bp.route('/rounds/<round_id>/votes', methods=['POST'])
def cast_vote(round_id):
    """Проголосовать"""
    round = Round.query.get(round_id)
    
    if not round:
        return jsonify({'error': 'Round not found'}), 404
    
    if not round.is_active:
        return jsonify({'error': 'Round is not active'}), 400
    
    data = request.get_json()
    player_id = data.get('player_id')
    value = data.get('value')
    
    if not player_id:
        return jsonify({'error': 'player_id is required'}), 400
    
    if value is not None and (not isinstance(value, int) or value < 0):
        return jsonify({'error': 'value must be a non-negative integer'}), 400
    
    # Проверяем что игрок существует в этой комнате
    player = Player.query.get(player_id)
    if not player or player.room_id != round.room_id:
        return jsonify({'error': 'Player not found in this room'}), 404
    
    # Ищем существующий голос или создаём новый
    vote = Vote.query.filter_by(round_id=round_id, player_id=player_id).first()
    
    if vote:
        vote.value = value
    else:
        vote = Vote(round_id=round_id, player_id=player_id, value=value)
        db.session.add(vote)
    
    db.session.commit()
    
    # Отправляем событие WebSocket
    socketio.emit('vote_cast', {
        'round_id': round_id,
        'player_id': player_id,
        'voted': value is not None
    }, room=player.room_id)
    
    return jsonify({'vote_id': vote.id, 'voted': value is not None})


@bp.route('/rounds/<round_id>/reveal', methods=['POST'])
def reveal_votes(round_id):
    """Вскрыть карты (только ведущий)"""
    round = Round.query.get(round_id)
    
    if not round:
        return jsonify({'error': 'Round not found'}), 404
    
    data = request.get_json()
    host_id = data.get('host_id')
    
    # Проверка что запрашивающий - ведущий
    room = Room.query.get(round.room_id)
    host = Player.query.filter_by(room_id=room.id, role=Role.HOST).first()
    if not host or host.id != host_id:
        return jsonify({'error': 'Only host can reveal votes'}), 403
    
    if not round.is_active:
        return jsonify({'error': 'Round is not active'}), 400
    
    round.revealed_at = datetime.utcnow()
    round.is_active = False
    db.session.commit()
    
    # Получаем все голоса
    votes_data = [
        {
            'player_id': v.player_id,
            'player_nickname': v.player.nickname,
            'value': v.value
        }
        for v in round.votes
    ]
    
    # Отправляем событие WebSocket
    socketio.emit('round_revealed', {
        'round_id': round_id,
        'votes': votes_data
    }, room=room.id)
    
    return jsonify({
        'round_id': round_id,
        'votes': votes_data
    })
