import 'package:flutter/material.dart';
import '../../features/chess/presentation/screens/game_screen.dart';
import '../../features/chess/presentation/screens/home_screen.dart';
import '../../features/chess/presentation/screens/settings_screen.dart';
import '../../features/chess/presentation/screens/profile_screen.dart';
import '../../features/chess/presentation/screens/result_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String game = '/game';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String result = '/result';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case result:
        return _fade(
          ResultScreen(
            args: routeSettings.arguments as ResultArgs,
          ),
        );
      case home:
        return _fade(const HomeScreen());
      case game:
        final args = routeSettings.arguments as GameArgs?;
        return _fade(GameScreen(args: args ?? const GameArgs()));
      case settings:
        return _slide(const SettingsScreen());
      case profile:
        return _slide(const ProfileScreen());
      default:
        return _fade(const HomeScreen());
    }
  }

  static PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
    transitionDuration: const Duration(milliseconds: 250),
  );

  static PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class GameArgs {
  final String playerColor; // 'white' | 'black' | 'random'
  final int? timeSeconds;   // null = без таймера

  const GameArgs({
    this.playerColor = 'white',
    this.timeSeconds,
  });
}