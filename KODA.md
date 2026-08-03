# Scrum Poker LLM — Контекст проекта

## Обзор проекта

**Scrum Poker LLM** — мини веб-приложение для проведения scrum-покера, разработанное совместно с AI-помощником Koda.

**Основные возможности:**
* **Ведущий** — создаёт комнаты, проводит раунды, участвует в голосовании, вскрывает карты
* **Участник** — подключается к комнате, участвует в раундах, голосует
* **Наблюдатель** — просматривает раунды без участия

**Доступно по адресу:** https://safonovpro.github.io/scrum-poker-llm

## Стек технологий

### Frontend
* **React** на TypeScript
* **shadcn/ui** — UI-компоненты
* **Vite** — сборщик и dev-сервер
* **react-router-dom** — роутинг
* **socket.io-client** — WebSocket-клиент для real-time синхронизации

### Backend
* **Python** + **Flask** — основной framework
* **SQLAlchemy** — ORM
* **Alembic** — миграции БД
* **PostgreSQL 15** — база данных
* **python-socketio** — WebSocket-сервер

### Инфраструктура
* **Podman** / **Docker** — контейнеризация
* **GitHub Pages** — деплой фронтенда
* **VPS** — деплой backend

## Структура проекта

```
.
├── frontend/              # React + Vite приложение
│   ├── src/               # Исходный код
│   │   ├── components/    # UI компоненты
│   │   ├── pages/         # Страницы приложения
│   │   └── main.tsx       # Точка входа
│   ├── package.json
│   ├── vite.config.ts
│   └── index.html
├── backend/               # Flask API + WebSockets
│   ├── app/               # Основное приложение
│   │   ├── __init__.py    # Flask-приложение
│   │   ├── models.py      # SQLAlchemy модели
│   │   └── routes.py      # API endpoints
│   ├── alembic/           # Миграции БД
│   ├── Dockerfile
│   ├── alembic.ini
│   └── requirements.txt
├── scripts/               # Утилиты разработки и деплоя
│   ├── setup.sh           # Настройка виртуального окружения
│   ├── run-backend.sh     # Запуск backend
│   └── README.md
├── llm_logs/              # Логи сессий разработки с AI
├── docker-compose.yml     # Dev-конфигурация (PostgreSQL)
├── docker-compose.prod.yml # Prod-конфигурация
├── .env.example           # Пример переменных окружения
├── DEPLOY.md              # Инструкция по деплою
└── README.md              # Основная документация
```

## Сборка и запуск

### Первый запуск

```bash
# Настроить виртуальное окружение для backend
./scripts/setup.sh

# Запустить PostgreSQL
podman compose up -d
```

### Ежедневная разработка

```bash
# Запустить PostgreSQL (если не запущен)
podman compose up -d

# Запустить backend (в терминале 1)
./scripts/run-backend.sh

# Запустить frontend (в терминале 2)
cd frontend
npm run dev
```

**URL-адреса:**
* Backend: http://localhost:5000
* Frontend: http://localhost:3000

### Сборка и деплой

```bash
# Frontend production build
cd frontend
npm run build

# Backend production deploy
podman compose -f docker-compose.prod.yml up -d --build

# Миграции БД на production
docker compose -f docker-compose.prod.yml exec backend alembic upgrade head
```

## API Endpoints

### Комнаты
| Метод | Endpoint | Описание |
|-------|----------|----------|
| POST | `/api/rooms` | Создать комнату (`name`, `host_nickname`) |
| GET | `/api/rooms/:id` | Получить информацию о комнате |
| POST | `/api/rooms/:id/join` | Присоединиться к комнате (`nickname`, `role`) |

### Раунды
| Метод | Endpoint | Описание |
|-------|----------|----------|
| POST | `/api/rooms/:id/rounds` | Начать раунд (`task_description`, `host_id`) |

### Голоса
| Метод | Endpoint | Описание |
|-------|----------|----------|
| POST | `/api/rounds/:id/votes` | Проголосовать (`player_id`, `value`) |
| POST | `/api/rounds/:id/reveal` | Вскрыть карты (`host_id`) |

### WebSocket события

| Событие | Направление | Описание |
|---------|-------------|----------|
| `connect` | client → server | Подключение клиента |
| `disconnect` | client → server | Отключение клиента |
| `join_room` | client → server | Подключение к комнате |
| `leave_room` | client → server | Покидание комнаты |
| `room_created` | server → client | Комната создана |
| `player_joined` | server → client | Игрок присоединился |
| `player_left` | server → client | Игрок покинул комнату |
| `round_started` | server → client | Раунд начался |
| `vote_cast` | server → client | Голос подан |
| `round_revealed` | server → client | Карты вскрыты |

## Деплой

### Frontend — GitHub Pages
1. Включить GitHub Pages в настройках репозитория (Source: GitHub Actions)
2. Добавить секрет `VITE_API_URL` (URL backend сервера)
3. При push в main фронтенд автоматически собирается и публикуется

### Backend — VPS с Podman/Docker
Подробная инструкция: **[DEPLOY.md](DEPLOY.md)**

## Разработка

### Переменные окружения
Необходимо скопировать `.env.example` в `.env` и заполнить значения:
* `SECRET_KEY` — секретный ключ Flask
* `POSTGRES_PASSWORD` — пароль PostgreSQL
* `POSTGRES_USER` — пользователь PostgreSQL
* `POSTGRES_DB` — имя базы данных
* `VITE_API_URL` — URL backend для frontend

### Миграции БД
```bash
# Создать миграцию
alembic revision --autogenerate -m "описание"

# Применить миграции
alembic upgrade head
```

## Логи сессий разработки
В папке `llm_logs/` хранятся логи сессий разработки с AI-помощником. Файлы названы по шаблону `YYYY-MM-DD_HH:MM.md`.
