import os
from dotenv import load_dotenv

# Загружаем переменные окружения из .env
load_dotenv()

from flask import Flask
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_socketio import SocketIO

db = SQLAlchemy()
socketio = SocketIO(cors_allowed_origins="*", async_mode="threading")

def create_app():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret-key')
    app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', 'postgresql://scrum_poker:scrum_poker_password@db:5432/scrum_poker')
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    CORS(app)
    db.init_app(app)
    socketio.init_app(app)

    # Import models to register them with SQLAlchemy
    from . import models

    # Import socket handlers
    from . import socket as socket_handlers

    from .routes import bp as routes_bp
    app.register_blueprint(routes_bp, url_prefix='/api')

    return app
