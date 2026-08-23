import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/room_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/room/:roomId',
        name: 'room',
        builder: (_, state) => RoomScreen(
          roomId: state.pathParameters['roomId']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (_, __) => const AboutScreen(),
      ),
    ],
  );
}
