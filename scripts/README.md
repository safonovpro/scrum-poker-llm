# Скрипты для разработки

## Локальная разработка

### 1. Первый запуск (setup)

```bash
./scripts/setup.sh
```

### 2. Запуск PostgreSQL (только один раз)

```bash
podman compose up -d
```

### 3. Запуск backend

```bash
./scripts/run-backend.sh
```

Или вручную:

```bash
source backend/venv/bin/activate
export FLASK_APP=app
export FLASK_ENV=development
flask run --host=0.0.0.0 --port=5000
```

### 4. Запуск frontend

```bash
cd frontend
npm run dev
```

## Остановка

```bash
# Backend - Ctrl+C
# Frontend - Ctrl+C
# PostgreSQL
podman compose down
```
