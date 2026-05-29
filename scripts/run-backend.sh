#!/bin/bash

# Запуск backend'а локально

cd backend
source venv/bin/activate
export FLASK_APP=app
export FLASK_ENV=development

echo "🚀 Запуск backend'а..."
flask run --host=0.0.0.0 --port=5000
