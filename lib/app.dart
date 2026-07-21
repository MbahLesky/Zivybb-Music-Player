import 'package:flutter/material.dart';

import 'features/library/presentation/library_screen.dart';
import 'routes/app_routes.dart';

/// Root widget for the Zivybb application.
///
/// Owns app-wide concerns (theme, routing) that don't belong to any single
/// feature.
class ZivybbApp extends StatelessWidget {
  const ZivybbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zivybb',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.library,
      routes: {AppRoutes.library: (_) => const LibraryScreen()},
    );
  }
}
