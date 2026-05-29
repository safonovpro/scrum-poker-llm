from flask import request
from flask_socketio import join_room, leave_room
from . import socketio
from .models import Room, Player


@socketio.on('connect')
def handle_connect():
    print(f'Client connected: {request.sid}')


@socketio.on('disconnect')
def handle_disconnect():
    print(f'Client disconnected: {request.sid}')


@socketio.on('join_room')
def handle_join_room(data):
    """Подключиться к комнате WebSocket"""
    room_id = data.get('room_id')
    
    if room_id:
        join_room(room_id)
        print(f'✅ Client {request.sid} joined room {room_id}')
        
        # Проверим кто подключился
        room = Room.query.get(room_id)
        if room:
            players_count = room.players.count()
            print(f'   Room: {room.name}, Players: {players_count}')
            print(f'   📡 Now listening for events in this room')


@socketio.on('leave_room')
def handle_leave_room(data):
    """Покинуть комнату WebSocket"""
    room_id = data.get('room_id')
    
    if room_id:
        leave_room(room_id)
        print(f'Client {request.sid} left room {room_id}')
