#!/bin/bash

# Setup для локальной разработки

echo "🔧 Настройка виртуального окружения..."
cd backend
python3 -m venv venv

echo "📦 Установка зависимостей..."
source venv/bin/activate
pip install -r requirements.txt

echo "✅ Готово! Активируй виртуальное окружение:"
echo "   source backend/venv/bin/activate"
