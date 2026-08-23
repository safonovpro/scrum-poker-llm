import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'blocs/app_bloc.dart';
import 'services/api_service.dart';
import 'services/socket_service.dart';
import 'services/session_service.dart';
import 'app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final baseUrl = prefs.getString('backend_url') ?? 'http://localhost:5000';
  
  final apiService = ApiService(baseUrl);
  final socketService = SocketService(baseUrl);
  final sessionService = SessionService();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<SocketService>.value(value: socketService),
        Provider<SessionService>.value(value: sessionService),
        BlocProvider(
          create: (_) => AppBloc(
            apiService: apiService,
            socketService: socketService,
            sessionService: sessionService,
          )..add(LoadSavedPlayerEvent()),
        ),
      ],
      child: const ScrumPokerApp(),
    ),
  );
}

class ScrumPokerApp extends StatelessWidget {
  const ScrumPokerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Scrum Poker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('ru'),
        Locale('en'),
      ],
      routerConfig: AppRouter.router,
    );
  }
}
