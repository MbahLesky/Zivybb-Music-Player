import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
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
    final seedColor = ref.watch(themeSeedColorProvider);
    final style = ref.watch(appThemeStyleProvider);

    return MaterialApp(
      title: 'Zivybb',
      themeMode: themeMode,
      theme: buildAppTheme(
        brightness: Brightness.light,
        style: style,
        seedColor: seedColor,
      ),
      darkTheme: buildAppTheme(
        brightness: Brightness.dark,
        style: style,
        seedColor: seedColor,
      ),
      initialRoute: AppRoutes.library,
      routes: {AppRoutes.library: (_) => const LibraryScreen()},
    );
  }
}
