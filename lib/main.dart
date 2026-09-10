import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'core/stats/player_stats.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PlayerStats().load();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppSettings(),
      child: const ChessAIApp(),
    ),
  );
}

class ChessAIApp extends StatelessWidget {
  const ChessAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess AI: Robert Paulson',
      theme: AppTheme.darkTheme,
      onGenerateRoute: AppRouter.generateRoute,
      initialRoute: AppRouter.home,
      debugShowCheckedModeBanner: false,
    );
  }
}