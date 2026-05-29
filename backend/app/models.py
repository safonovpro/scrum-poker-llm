from datetime import datetime
from enum import Enum
from . import db


class Role(Enum):
    """Роли участников в комнате"""
    HOST = 'host'
    PLAYER = 'player'
    OBSERVER = 'observer'


class Room(db.Model):
    """Комната для игры в Scrum Poker"""
    __tablename__ = 'rooms'

    id = db.Column(db.String(36), primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    is_active = db.Column(db.Boolean, default=True)

    # Связи
    players = db.relationship('Player', backref='room', lazy='dynamic', cascade='all, delete-orphan')
    rounds = db.relationship('Round', backref='room', lazy='dynamic', cascade='all, delete-orphan')

    def __repr__(self):
        return f'<Room {self.id}: {self.name}>'


class Player(db.Model):
    """Участник комнаты"""
    __tablename__ = 'players'

    id = db.Column(db.String(36), primary_key=True)
    room_id = db.Column(db.String(36), db.ForeignKey('rooms.id'), nullable=False)
    nickname = db.Column(db.String(100), nullable=False)
    role = db.Column(db.Enum(Role), default=Role.PLAYER, nullable=False)
    joined_at = db.Column(db.DateTime, default=datetime.utcnow)
    is_ready = db.Column(db.Boolean, default=False)

    # Связи
    votes = db.relationship('Vote', backref='player', lazy='dynamic', cascade='all, delete-orphan')

    def __repr__(self):
        return f'<Player {self.nickname} ({self.role.value})>'


class Round(db.Model):
    """Раунд голосования"""
    __tablename__ = 'rounds'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    room_id = db.Column(db.String(36), db.ForeignKey('rooms.id'), nullable=False)
    task_description = db.Column(db.Text, nullable=True)
    started_at = db.Column(db.DateTime, default=datetime.utcnow)
    revealed_at = db.Column(db.DateTime, nullable=True)
    is_active = db.Column(db.Boolean, default=True)

    # Связи
    votes = db.relationship('Vote', backref='round', lazy='dynamic', cascade='all, delete-orphan')

    def __repr__(self):
        return f'<Round {self.id} for room {self.room_id}>'


class Vote(db.Model):
    """Голос игрока в раунде"""
    __tablename__ = 'votes'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    round_id = db.Column(db.Integer, db.ForeignKey('rounds.id'), nullable=False)
    player_id = db.Column(db.String(36), db.ForeignKey('players.id'), nullable=False)
    value = db.Column(db.Integer, nullable=True)  # NULL пока карты не вскрыты
    voted_at = db.Column(db.DateTime, default=datetime.utcnow)

    __table_args__ = (
        # Один голос на игрока в раунде
        db.UniqueConstraint('round_id', 'player_id', name='uq_round_player'),
    )

    def __repr__(self):
        return f'<Vote {self.value} by {self.player_id} in round {self.round_id}>'
