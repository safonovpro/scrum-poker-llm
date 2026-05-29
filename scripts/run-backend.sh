#!/bin/bash

# Запуск backend'а локально

cd backend
source venv/bin/activate

echo "🚀 Запуск backend'а..."
python -c "
from app import create_app, socketio
app = create_app()
socketio.run(app, host='0.0.0.0', port=5000, debug=True, allow_unsafe_werkzeug=True)
"
