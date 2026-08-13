import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/models/song.dart';
import 'package:zivybb/features/vibe_tagging/presentation/vibe_tagging_screen.dart';

const _song = Song(
  id: '1',
  filePath: '/music/a.mp3',
  title: 'A Song',
  artist: 'Artist',
  album: 'Album',
  duration: Duration(minutes: 3),
);

/// Seeds [count] vibes spread across two folders, enough to overflow a
/// bottom sheet on a phone-sized viewport.
Future<AppDatabase> _databaseWith(int count) async {
  final database = AppDatabase.connect(NativeDatabase.memory());

  for (final (index, id) in ['mood', 'place'].indexed) {
    await database
        .into(database.vibeCategories)
        .insert(
          VibeCategoriesCompanion.insert(
            id: id,
            name: id == 'mood' ? 'Mood' : 'Place',
            colorHex: '#7E57C2',
            sortOrder: Value(index),
          ),
        );
  }
  for (var i = 0; i < count; i++) {
    await database
        .into(database.vibeTags)
        .insert(
          VibeTagsCompanion.insert(
            id: 'vibe-$i',
            label: 'A fairly long vibe name $i',
            colorHex: '#FF7043',
            sortOrder: Value(i),
            categoryId: Value(i.isEven ? 'mood' : 'place'),
          ),
        );
  }
  return database;
}

Future<void> _openSheet(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => VibeTaggingSheet.show(context, _song),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

/// Unmounts inside the test body so drift's zero-duration cleanup timer
/// fires here rather than tripping the "no pending timers" check.
Future<void> _teardown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  testWidgets('a long vibe list scrolls instead of overflowing', (
    tester,
  ) async {
    // Regression test: the sheet was a plain Column in a default-height
    // bottom sheet, so any vibe list taller than half the screen threw a
    // bottom-overflow error instead of scrolling.
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final database = await _databaseWith(40);
    await _openSheet(tester, database);

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsWidgets);

    // Something below the fold must be reachable by scrolling.
    await tester.scrollUntilVisible(
      find.text('A fairly long vibe name 39'),
      200,
      scrollable: find.descendant(
        of: find.byType(VibeTaggingSheet),
        matching: find.byType(Scrollable),
      ),
    );
    expect(find.text('A fairly long vibe name 39'), findsOneWidget);

    await _teardown(tester);
  });

  testWidgets('chips are grouped under their folder', (tester) async {
    final database = await _databaseWith(4);
    await _openSheet(tester, database);

    expect(find.text('MOOD'), findsOneWidget);
    expect(find.text('PLACE'), findsOneWidget);

    await _teardown(tester);
  });

  testWidgets('a short list still lays out without overflowing', (
    tester,
  ) async {
    final database = await _databaseWith(2);
    await _openSheet(tester, database);

    expect(tester.takeException(), isNull);
    expect(find.text('Vibes for "A Song"'), findsOneWidget);

    await _teardown(tester);
  });
}
