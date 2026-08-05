import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/app.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/features/settings/presentation/settings_screen.dart';

void main() {
  testWidgets(
    'Settings screen shows grouped theme, playback, visualizer, library, and '
    'display sections',
    (WidgetTester tester) async {
      final database = AppDatabase.connect(NativeDatabase.memory());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Playback'), findsOneWidget);
      expect(find.text('Visualizer'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Display'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 1));
    },
  );

  testWidgets('a switch inside a settings section updates as it is toggled', (
    WidgetTester tester,
  ) async {
    // Regression test: the section's controls used to be built eagerly by
    // SettingsScreen and handed to the pushed route, so they kept rendering
    // the settings values captured when the category was tapped. Toggling
    // wrote to the database but the switch stayed put until the section was
    // closed and reopened.
    final database = AppDatabase.connect(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Display'));
    await tester.pumpAndSettle();

    final albumArtSwitch = find.widgetWithText(
      SwitchListTile,
      'Album art in mini player',
    );
    expect(tester.widget<SwitchListTile>(albumArtSwitch).value, isTrue);

    await tester.tap(albumArtSwitch);
    await tester.pumpAndSettle();

    expect(
      tester.widget<SwitchListTile>(albumArtSwitch).value,
      isFalse,
      reason: 'the visible switch must follow the persisted value',
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('ZivybbApp builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(
            AppDatabase.connect(NativeDatabase.memory()),
          ),
        ],
        child: const ZivybbApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Zivybb'), findsOneWidget);

    // Drift's watched-query cleanup schedules a zero-duration timer on
    // cancellation; unmount within the test body so it fires here instead of
    // tripping the framework's post-test "no pending timers" check.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
