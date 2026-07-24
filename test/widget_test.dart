import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/app.dart';
import 'package:zivybb/data/datasources/app_database.dart';

void main() {
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
