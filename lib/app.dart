import 'package:flutter/material.dart';

/// Root widget for the Zivybb application.
///
/// Owns app-wide concerns (theme, routing) that don't belong to any single
/// feature. Feature screens are wired in as the corresponding routes land.
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
      home: const _PlaceholderHome(),
    );
  }
}

class _PlaceholderHome extends StatelessWidget {
  const _PlaceholderHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Zivybb')));
  }
}
