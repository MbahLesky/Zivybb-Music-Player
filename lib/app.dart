import 'package:flutter/material.dart';

import 'app_scope.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

/// Root widget for the Zivybb application.
///
/// Owns app-wide concerns (theme, routing) that don't belong to any single
/// feature. Feature screens are wired in as the corresponding routes land.
class ZivybbApp extends StatelessWidget {
  const ZivybbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScope(
      child: MaterialApp(
        title: 'Zivybb',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        // Zivybb Dark is the default base. Time-of-day switching and the
        // manual override arrive with the settings screen (Week 2 Day 5).
        themeMode: ThemeMode.dark,
        initialRoute: AppRoutes.library,
        routes: AppRoutes.routes,
      ),
    );
  }
}
