import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/library/presentation/library_screen.dart';
import 'features/settings/application/settings_controller.dart';
import 'routes/app_routes.dart';

/// Root widget for the Zivybb application.
///
/// Owns app-wide concerns (theme, routing) that don't belong to any single
/// feature.
class ZivybbApp extends ConsumerWidget {
  const ZivybbApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Zivybb',
      themeMode: themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.library,
      routes: {AppRoutes.library: (_) => const LibraryScreen()},
    );
  }
}
