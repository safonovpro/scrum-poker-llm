# Handoff: Scrum Poker Mobile — Flutter

**От:** Текущая сессия  
**Для:** Следующий агент  
**Дата:** 2026-08-23  
**Фокус сессии:** Создание Android-приложения для Scrum Poker на Flutter

---

## Что сделано

### 1. Дизайн-сессия (grilling)

Проведено интервью по дереву решений для создания мобильного приложения. Утверждены:

- **Стек:** Flutter (Dart), BLoC, go_router, socket_io_client, http
- **Архитектура:** Один AppBloc, ApiService, SocketService
- **UI:** Material 3, точная копия веб-версии
- **Навигация:** go_router (4 экрана)
- **Деплой:** Firebase App Distribution

### 2. Сгенерированная кодовая база (`mobile/`)

Полная структура проекта Flutter:

```
mobile/
├── pubspec.yaml             # Зависимости
├── analysis_options.yaml     # Линтинг
├── .gitignore
├── README.md                 # Документация
└── lib/
    ├── main.dart             # Точка входа, MultiBlocProvider
    ├── app_router.dart       # go_router (4 роута)
    ├── theme/app_theme.dart  # Светлая/тёмная тема
    ├── models/
    │   ├── role.dart         # enum: host, player, observer
    │   ├── player.dart       # Data class + JSON
    │   ├── room.dart         # Data class + copyWith
    │   ├── round.dart        # Data class + copyWith
    │   └── vote.dart         # Data class + JSON
    ├── services/
    │   ├── api_service.dart  # REST API (6 методов)
    │   └── socket_service.dart # WebSocket (6 event-стримов)
    ├── blocs/
    │   └── app_bloc.dart    # Единый BLoC (7 событий, 6 слушателей)
    ├── screens/
    │   ├── home_screen.dart # Создание + вступление
    │   ├── room_screen.dart # Комната, карты, FAB
    │   ├── settings_screen.dart # Тема + URL
    │   └── about_screen.dart # Версия, GitHub, "Made with Koda"
    └── widgets/
        ├── player_list.dart  # Игроки + статус
        ├── vote_cards.dart   # Колода Фибоначчи
        └── reveal_panel.dart # Результаты + статистика
```

### 3. Интеграция с бэкендом

Код адаптирован под реальные API-эндпоинты и WebSocket-события из `backend/app/routes.py` и `backend/app/socket.py`:

**REST API:**
- `POST /api/rooms` → `createRoom()`
- `GET /api/rooms/:id` → `getRoom()`
- `POST /api/rooms/:id/join` → `joinRoom()`
- `POST /api/rooms/:id/rounds` → `startRound()`
- `POST /api/rounds/:id/votes` → `castVote()`
- `POST /api/rounds/:id/reveal` → `revealVotes()`

**WebSocket события:**
- `room_created`, `player_joined`, `player_left`
- `round_started`, `vote_cast`, `round_revealed`

---

## Что нужно сделать дальше

### Критично

1. **Проверить сборку:** `flutter pub get && flutter analyze`
2. **Исправить импорты:** Проверить все `import` пути
3. **Настроить Android:** `android/app/src/main/AndroidManifest.xml` — добавить интернет-разрешение
4. **Настроить networking:** `android/app/src/main/AndroidManifest.xml` — `android:usesCleartextTraffic="true"` для HTTP

### Важно

5. **Обработка ошибок:** В `ApiService` бросаются `Exception`, но в BLoC нет `try/catch` для некоторых методов
6. **Сохранение сессии:** `LoadSavedPlayerEvent` в BLoC — TODO (нужна реализация с SharedPreferences)
7. **Обновление UI при WebSocket:** Некоторые слушатели (`_onRoomCreated`, `_onVoteCast`) пустые — нужно обновлять состояние
8. **Тесты:** Нет автотестов

### Желательно

9. **Анимации:** Добавить анимации для карт, FAB, переходов
10. **Haptic feedback:** Для тактильной обратной связи при выборе карт
11. **Deep links:** Настроить открытие по ссылке на комнату
12. **Локализация:** Добавить поддержку русского/английского
13. **CI/CD:** Настроить GitHub Actions для сборки APK

---

## Ключевые решения

| Решение | Выбор | Обоснование |
|---------|-------|-------------|
| Фреймворк | Flutter | Кроссплатформенность, один код для Android/iOS |
| Управление состоянием | BLoC | Больше примеров, проще для LLM |
| Навигация | go_router | Named routes, deep links |
| WebSocket | socket_io_client | Совместимость с python-socketio |
| HTTP | http | Минимализм |
| Данные | Ручные классы | Проще, без code generation |
| UI | Material 3 | Стандарт, быстро |
| Структура | По экранам | Проще для маленького проекта |

---

## Связанные файлы

- **Веб-версия:** `frontend/` — React + Vite
- **Бэкенд:** `backend/` — Flask + SQLAlchemy
- **Документация проекта:** `KODA.md`
- **Дизайн-решения:** `skills/README-DETAILED.md`

---

## Suggested Skills

Следующему агенту могут пригодиться:

- **[grilling](./skills/grilling/SKILL.md)** — Для принятия архитектурных решений по доработкам
- **[implement](./skills/implement/SKILL.md)** — Для реализации конкретных фич
- **[tdd](./skills/tdd/SKILL.md)** — Для написания тестов
- **[to-spec](./skills/to-spec/SKILL.md)** — Для создания спецификаций доработок

---

## Примечания

- Приложение использует HTTP (не HTTPS) для локальной разработки — нужен `usesCleartextTraffic`
- Бэкенд по умолчанию: `http://localhost:5000`
- Числа на картах: Фибоначчи `[0, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89]`
- Деплой: Firebase App Distribution (не Play Store)
