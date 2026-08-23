import 'package:flutter/material.dart';

class AppLocalizations {
  final String languageCode;

  AppLocalizations(this.languageCode);

  static AppLocalizations of(BuildContext context) {
    return AppLocalizations(
      Localizations.localeOf(context).languageCode,
    );
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'ru': {
      'appTitle': 'Scrum Poker',
      'createRoom': 'Создать комнату',
      'roomName': 'Название комнаты',
      'roomNameHint': 'Спринт 12',
      'nickname': 'Ваш псевдоним',
      'nicknameHint': 'Алексей',
      'create': 'Создать',
      'creating': 'Создание...',
      'joinRoom': 'Вступить в комнату',
      'inviteLink': 'Ссылка на комнату',
      'inviteLinkHint': 'https://.../room/abc-123',
      'join': 'Вступить',
      'joining': 'Вступление...',
      'settings': 'Настройки',
      'server': 'Сервер',
      'backendUrl': 'URL бэкенда',
      'backendUrlHint': 'http://localhost:5000',
      'darkMode': 'Тёмная тема',
      'darkModeSubtitle': 'Использовать тёмное оформление',
      'save': 'Сохранить',
      'saving': 'Сохранение...',
      'settingsSaved': 'Настройки сохранены. Перезапустите приложение.',
      'about': 'О приложении',
      'version': 'Версия',
      'sourceCode': 'Исходный код',
      'madeWithKoda': 'Сделано с помощью Koda',
      'roomNotFound': 'Комната не найдена',
      'roundActive': 'Раунд активен',
      'roundFinished': 'Раунд завершён',
      'revealCards': 'Вскрыть карты',
      'startRound': 'Начать раунд',
      'startRoundTitle': 'Начать раунд',
      'taskDescription': 'Описание задачи (необязательно)',
      'cancel': 'Отмена',
      'start': 'Начать',
      'revealTitle': 'Вскрыть карты?',
      'revealContent': 'Все голоса будут показаны участникам.',
      'reveal': 'Вскрыть',
      'results': 'Результаты',
      'average': 'Среднее',
      'median': 'Медиана',
      'min': 'Мин',
      'max': 'Макс',
      'host': 'Ведущий',
      'player': 'Участник',
      'observer': 'Наблюдатель',
      'loading': 'Загрузка...',
      'createError': 'Ошибка создания комнаты',
      'joinError': 'Ошибка вступления в комнату',
    },
    'en': {
      'appTitle': 'Scrum Poker',
      'createRoom': 'Create Room',
      'roomName': 'Room Name',
      'roomNameHint': 'Sprint 12',
      'nickname': 'Your Nickname',
      'nicknameHint': 'Alex',
      'create': 'Create',
      'creating': 'Creating...',
      'joinRoom': 'Join Room',
      'inviteLink': 'Room Link',
      'inviteLinkHint': 'https://.../room/abc-123',
      'join': 'Join',
      'joining': 'Joining...',
      'settings': 'Settings',
      'server': 'Server',
      'backendUrl': 'Backend URL',
      'backendUrlHint': 'http://localhost:5000',
      'darkMode': 'Dark Mode',
      'darkModeSubtitle': 'Use dark theme',
      'save': 'Save',
      'saving': 'Saving...',
      'settingsSaved': 'Settings saved. Restart the app.',
      'about': 'About',
      'version': 'Version',
      'sourceCode': 'Source Code',
      'madeWithKoda': 'Made with Koda',
      'roomNotFound': 'Room not found',
      'roundActive': 'Round active',
      'roundFinished': 'Round finished',
      'revealCards': 'Reveal Cards',
      'startRound': 'Start Round',
      'startRoundTitle': 'Start Round',
      'taskDescription': 'Task description (optional)',
      'cancel': 'Cancel',
      'start': 'Start',
      'revealTitle': 'Reveal Cards?',
      'revealContent': 'All votes will be shown to participants.',
      'reveal': 'Reveal',
      'results': 'Results',
      'average': 'Average',
      'median': 'Median',
      'min': 'Min',
      'max': 'Max',
      'host': 'Host',
      'player': 'Player',
      'observer': 'Observer',
      'loading': 'Loading...',
      'createError': 'Error creating room',
      'joinError': 'Error joining room',
    },
  };

  String t(String key) {
    return _localizedValues[languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  String get appTitle => t('appTitle');
  String get createRoom => t('createRoom');
  String get roomName => t('roomName');
  String get roomNameHint => t('roomNameHint');
  String get nickname => t('nickname');
  String get nicknameHint => t('nicknameHint');
  String get create => t('create');
  String get creating => t('creating');
  String get joinRoom => t('joinRoom');
  String get inviteLink => t('inviteLink');
  String get inviteLinkHint => t('inviteLinkHint');
  String get join => t('join');
  String get joining => t('joining');
  String get settings => t('settings');
  String get server => t('server');
  String get backendUrl => t('backendUrl');
  String get backendUrlHint => t('backendUrlHint');
  String get darkMode => t('darkMode');
  String get darkModeSubtitle => t('darkModeSubtitle');
  String get save => t('save');
  String get saving => t('saving');
  String get settingsSaved => t('settingsSaved');
  String get about => t('about');
  String get version => t('version');
  String get sourceCode => t('sourceCode');
  String get madeWithKoda => t('madeWithKoda');
  String get roomNotFound => t('roomNotFound');
  String get roundActive => t('roundActive');
  String get roundFinished => t('roundFinished');
  String get revealCards => t('revealCards');
  String get startRound => t('startRound');
  String get startRoundTitle => t('startRoundTitle');
  String get taskDescription => t('taskDescription');
  String get cancel => t('cancel');
  String get start => t('start');
  String get revealTitle => t('revealTitle');
  String get revealContent => t('revealContent');
  String get reveal => t('reveal');
  String get results => t('results');
  String get average => t('average');
  String get median => t('median');
  String get min => t('min');
  String get max => t('max');
  String get host => t('host');
  String get player => t('player');
  String get observer => t('observer');
  String get loading => t('loading');
  String get createError => t('createError');
  String get joinError => t('joinError');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale.languageCode);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}