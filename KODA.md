# KODA.md — Контекст проекта Scrum Poker LLM

## Обзор проекта

**Scrum Poker LLM** — миниатюрное веб-приложение для проведения скрам-покера (оценивания задач в Agile-командах). Разработано совместно с AI-помощником Koda от команды NLP-Core-Team.

Приложение позволяет ведущему создавать комнаты для голосования, участникам — подключаться и голосовать оценками (числами), а наблюдателям — следить за процессом. Состояние синхронизируется в реальном времени через WebSocket.

**Ролевая модель:**
- **Ведущий** — создаёт комнаты, запускает раунды, вскрывает карты
- **Участник** — подключается по ссылке, голосует в раундах
- **Наблюдатель** — подключается без ввода псевдонима, только наблюдает

## Стек технологий

| Компонент | Технология |
|-----------|-----------|
| Frontend | React 18 + TypeScript, Vite 5, React Router 6 |
| Backend | Python 3, Flask 3, SQLAlchemy, Alembic |
| Real-time | python-socketio (WebSocket + long-polling fallback) |
| База данных | PostgreSQL 15 |
| Сборка | Podman / Docker Compose |
| Деплой фронтенда | GitHub Pages (статический билд через GitHub Actions) |
| Деплой бэкенда | VPS с Podman/Docker |

## Архитектура

```
┌─────────────────────┐         HTTP / WebSocket        ┌─────────────────────┐
│   Frontend (React)  │ ──────────────────────────────► │   Backend (Flask)   │
│   Vite, TypeScript  │                                 │   Flask-SocketIO   │
│   HashRouter        │                                 │   SQLAlchemy ORM    │
│   AppContext (state)│                                 │   PostgreSQL        │
└─────────────────────┘                                 └─────────────────────┘
```

**Ключевые компоненты:**

- `frontend/src/contexts/AppContext.tsx` — единый источник состояния приложения: комната, текущий игрок, активный раунд, голоса, WebSocket-соединение. Все действия (создание комнаты, вступление, голосование, старт/раскрытие раунда) реализованы здесь.
- `backend/app/models.py` — четыре модели: `Room`, `Player`, `Round`, `Vote`. Связи «один-ко-многим» с каскадным удалением.
- `backend/app/routes.py` — REST API для комнат, раундов и голосов.
- `backend/app/socket.py` — обработчики WebSocket-событий (подключение, вступление, голосование, раскрытие).

## Сборка и запуск

### Локальная разработка

```bash
# 1. Настройка виртуального окружения (первый запуск)
./scripts/setup.sh

# 2. Запуск PostgreSQL (Podman)
podman compose up -d

# 3. Запуск backend (в одном терминале)
./scripts/run-backend.sh

# 4. Запуск frontend (в другом терминале)
cd frontend
npm run dev
```

- Backend: `http://localhost:5000`
- Frontend: `http://localhost:3000`

### Команды

| Действие | Команда |
|----------|---------|
| Настройка окружения | `./scripts/setup.sh` |
| Запуск PostgreSQL | `podman compose up -d` |
| Остановка PostgreSQL | `podman compose down` |
| Запуск backend | `./scripts/run-backend.sh` |
| Запуск frontend | `cd frontend && npm run dev` |
| Сборка frontend (production) | `cd frontend && npm run build` |
| Предпросмотр frontend | `cd frontend && npm run preview` |
| Деплой через Docker | `podman compose up -d --build` |

### Зависимости

**Backend** (`backend/requirements.txt`):
- `flask==3.0.0`, `flask-cors==4.0.0`, `flask-sqlalchemy==3.1.1`
- `flask-socketio==5.3.6`, `python-socketio==5.11.0`
- `psycopg2-binary==2.9.9`, `alembic==1.13.0`
- `python-dotenv==1.0.0`

**Frontend** (`frontend/package.json`):
- `react`, `react-dom`, `react-router-dom`, `socket.io-client`
- `typescript`, `vite`, `@vitejs/plugin-react`

## API Endpoints

### Комнаты
- `POST /api/rooms` — создать комнату (`name`, `host_nickname`)
- `GET /api/rooms/:id` — получить комнату

### Вступление
- `POST /api/rooms/:id/join` — вступить в комнату (`nickname`, `role`)

### Раунды
- `POST /api/rooms/:id/rounds` — начать раунд (`task_description`, `host_id`)

### Голоса
- `POST /api/rounds/:id/votes` — проголосовать (`player_id`, `value`)
- `POST /api/rounds/:id/reveal` — вскрыть карты (`host_id`)

## WebSocket-события

| Событие | Направление | Описание |
|---------|-------------|----------|
| `connect` | клиент → сервер | Подключение |
| `disconnect` | клиент → сервер | Отключение |
| `join_room` | клиент → сервер | Подписка на комнату |
| `leave_room` | клиент → сервер | Отписка от комнаты |
| `room_created` | сервер → клиент | Комната создана |
| `player_joined` | сервер → клиент | Игрок вступил |
| `player_left` | сервер → клиент | Игрок покинул |
| `round_started` | сервер → клиент | Раунд начался |
| `vote_cast` | сервер → клиент | Голос подан |
| `round_revealed` | сервер → клиент | Карты вскрыты |

## Структура проекта

```
.
├── frontend/              # React + Vite приложение
│   ├── src/
│   │   ├── contexts/      # AppContext — состояние + WebSocket
│   │   ├── pages/         # HomePage, RoomPage
│   │   ├── api.ts         # HTTP-клиент
│   │   ├── types.ts       # TypeScript-типы
│   │   └── App.tsx        # Роутинг
│   └── package.json
├── backend/               # Flask API + WebSockets
│   ├── app/
│   │   ├── __init__.py    # create_app(), инициализация db/socketio
│   │   ├── models.py      # Room, Player, Round, Vote
│   │   ├── routes.py      # REST endpoints
│   │   └── socket.py      # WebSocket handlers
│   ├── alembic/           # Миграции БД
│   └── requirements.txt
├── mobile/                # Flutter Android/iOS приложение
│   ├── lib/
│   │   ├── main.dart      # Точка входа, провайдеры
│   │   ├── app_router.dart # go_router конфигурация
│   │   ├── theme/         # Светлая/тёмная тема
│   │   ├── models/        # Room, Player, Round, Vote, Role
│   │   ├── services/      # ApiService, SocketService
│   │   ├── blocs/         # AppBloc
│   │   ├── screens/       # Home, Room, Settings, About
│   │   └── widgets/       # PlayerList, VoteCards, RevealPanel
│   ├── pubspec.yaml       # Зависимости Flutter
│   └── README.md
├── scripts/               # Утилиты
│   ├── setup.sh           # Настройка venv
│   └── run-backend.sh     # Запуск backend
├── llm_logs/              # Логи AI-сессий разработки
├── skills/                # Навыки Koda (не относятся к приложению)
│   └── README-DETAILED.md # Подробное описание всех навыков
├── docker-compose.yml     # PostgreSQL для разработки
└── docker-compose.prod.yml # Production-конфигурация
```

## Правила разработки

- **Backend:** Flask-приложение создаётся через фабрику `create_app()`. Модели и роутеры импортируются внутри функции для регистрации. Используется `python-dotenv` для загрузки `.env`.
- **Frontend:** Единый контекст `AppContext` управляет всем состоянием. WebSocket-соединение инициализируется один раз при монтировании `AppProvider`, слушатели используют `useRef` для доступа к актуальным значениям без пересоздания.
- **Роутинг:** `HashRouter` (для совместимости с GitHub Pages).
- **База данных:** Миграции через Alembic (`alembic upgrade head` / `alembic revision --autogenerate`).
- **Переменные окружения:** `.env.example` — шаблон. Ключевые: `DATABASE_URL`, `SECRET_KEY`, `VITE_API_URL` (для frontend production).
- **Деплой фронтенда:** GitHub Actions (`deploy-frontend.yml`) автоматически собирает и публикует при push в main.
- **Тестирование:** В проекте отсутствуют автотесты. При добавлении функциональности рекомендуется писать тесты для backend-маршрутов и логики контекста.

## Важные замечания

1. **Нет автотестов** — в проекте отсутствует тестовое покрытие. Любые изменения следует проверять вручную.
2. **Статический секрет** — `SECRET_KEY` по умолчанию `'dev-secret-key'`. Для production необходимо задать через переменную окружения.
3. **WebSocket-транспорты** — сервер использует `polling` + `websocket`, клиент по умолчанию только `polling` (для совместимости с прокси).
4. **LLM-логи** — в `llm_logs/` хранятся логи AI-сессий разработки в формате `YYYY-MM-DD_HH:MM.md`.
- **Skills** — директория `skills/` содержит навыки Koda CLI (рабочие методы для AI-агента). Подробное описание всех навыков: [skills/README-DETAILED.md](./skills/README-DETAILED.md).
