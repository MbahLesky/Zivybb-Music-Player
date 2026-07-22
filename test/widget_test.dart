import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/app.dart';

void main() {
  testWidgets('library screen lists the scanned songs', (tester) async {
    await tester.pumpWidget(const ZivybbApp());
    await tester.pumpAndSettle();

    expect(find.text('Zivybb'), findsOneWidget);
    expect(find.text('Neon Rain'), findsOneWidget);
    expect(find.text('Songs'), findsOneWidget);
  });

  testWidgets('tapping a song opens the mini-player', (tester) async {
    await tester.pumpWidget(const ZivybbApp());
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.pause), findsNothing);

    await tester.tap(find.text('Neon Rain'));
    await tester.pump();

    // The mini-player shows a pause control while the track is playing.
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.text('Neon Rain'), findsNWidgets(2));
  });

  testWidgets('a missing file is flagged instead of played', (tester) async {
    await tester.pumpWidget(const ZivybbApp());
    await tester.pumpAndSettle();

    await tester.dragUntilVisible(
      find.text('Ghost Track'),
      find.byType(ListView).first,
      const Offset(0, -120),
    );
    await tester.tap(find.text('Ghost Track'));
    await tester.pump();

    expect(find.text('"Ghost Track" is missing from storage.'), findsOneWidget);
    expect(find.byIcon(Icons.pause), findsNothing);
  });
}
