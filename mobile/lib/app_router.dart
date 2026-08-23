import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/room_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_screen.dart';

class _SlideTransitionPage extends CustomTransitionPage {
  _SlideTransitionPage({required super.child})
      : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        );
}

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        pageBuilder: (_, __) => const MaterialPage(child: HomeScreen()),
      ),
      GoRoute(
        path: '/room/:roomId',
        name: 'room',
        pageBuilder: (_, state) => _SlideTransitionPage(
          child: RoomScreen(
            roomId: state.pathParameters['roomId']!,
          ),
        ),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (_, __) => _SlideTransitionPage(
          child: const SettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        pageBuilder: (_, __) => _SlideTransitionPage(
          child: const AboutScreen(),
        ),
      ),
    ],
  );

  static Future<String?> _redirect(BuildContext context, GoRouterState state) async {
    final deepLink = state.uri.toString();
    // Обработка deep link: scrum-poker://room/{roomId}
    if (deepLink.startsWith('scrum-poker://room/')) {
      final roomId = deepLink.replaceFirst('scrum-poker://room/', '');
      return '/room/$roomId';
    }
    return null;
  }
}
