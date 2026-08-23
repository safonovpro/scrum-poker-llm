# Scrum Poker — Android (Flutter)

Мобильное приложение для проведения скрам-покера. Полностью повторяет функциональность веб-версии.

## Стек

- **Flutter** (Dart)
- **BLoC** — управление состоянием
- **go_router** — навигация
- **socket_io_client** — WebSocket
- **http** — REST API

## Структура

```
lib/
├── main.dart              # Точка входа
├── app_router.dart        # go_router конфигурация
├── theme/
│   └── app_theme.dart     # Светлая/тёмная тема
├── models/
│   ├── role.dart          # Role enum
│   ├── player.dart        # Модель игрока
│   ├── room.dart          # Модель комнаты
│   ├── round.dart         # Модель раунда
│   └── vote.dart          # Модель голоса
├── services/
│   ├── api_service.dart   # REST API клиент
│   └── socket_service.dart # WebSocket клиент
├── blocs/
│   └── app_bloc.dart      # Единый AppBloc
├── screens/
│   ├── home_screen.dart   # Главная (создать/вступить)
│   ├── room_screen.dart   # Комната
│   ├── settings_screen.dart # Настройки
│   └── about_screen.dart  # О приложении
└── widgets/
    ├── player_list.dart   # Список игроков
    ├── vote_cards.dart    # Колода карт (Фибоначчи)
    └── reveal_panel.dart  # Панель результатов
```

## Запуск

```bash
# Установка зависимостей
flutter pub get

# Запуск
flutter run

# Сборка APK
flutter build apk --release

# Сборка App Bundle (для Play Store)
flutter build appbundle --release
```

## Настройка бэкенда

По умолчанию приложение подключается к `http://localhost:5000`.
Для production измените URL в настройках приложения или в `lib/main.dart`.

## Деплой

Используется **Firebase App Distribution** для рассылки тестерам:

```bash
# Установка Firebase CLI
npm install -g firebase-tools

# Авторизация
firebase login

# Привязка проекта
firebase use --add

# Сборка и рассылка
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <FIREBASE_APP_ID> \
  --groups "testers"
```

## Архитектура

```
┌──────────────────┐     HTTP/WS      ┌──────────────────┐
│  Flutter App     │ ◄──────────────► │  Flask Backend   │
│                  │                  │                  │
│  AppBloc         │                  │  REST API        │
│  └─ Events       │                  │  WebSocket       │
│  └─ States       │                  │  PostgreSQL      │
│                  │                  │                  │
│  go_router       │                  │                  │
│  Material 3 UI   │                  │                  │
└──────────────────┘                  └──────────────────┘
```

## Роли

- **Ведущий** — создаёт комнаты, запускает раунды, вскрывает карты
- **Участник** — подключается по ссылке, голосует
- **Наблюдатель** — подключается без псевдонима, только наблюдает

## Числа на картах

Стандартная шкала Фибоначчи: `0, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89`
