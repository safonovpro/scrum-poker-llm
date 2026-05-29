from flask import Blueprint, request, jsonify
from . import db, socketio

bp = Blueprint('routes', __name__)

# Placeholder routes - будут реализованы по мере разработки
@bp.route('/rooms', methods=['POST'])
def create_room():
    return jsonify({'message': 'Room creation endpoint'}), 201

@bp.route('/rooms/<room_id>', methods=['GET'])
def get_room(room_id):
    return jsonify({'room_id': room_id})
