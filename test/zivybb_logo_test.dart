import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/shared/widgets/zivybb_logo.dart';

void main() {
  testWidgets('renders the brand artwork at the requested size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: ZivybbLogo(size: 40))),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, 40);
    expect(image.height, 40);
    expect(tester.getSize(find.byType(Image)), const Size(40, 40));
  });

  testWidgets('points at the artwork the launcher icons are cut from', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: ZivybbLogo())),
    );

    // tool/generate_icons.dart reads this same path; if one moves without the
    // other, the in-app logo and the launcher icon drift apart.
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      ZivybbLogo.assetPath,
      reason: 'keep in step with tool/generate_icons.dart',
    );
    expect(ZivybbLogo.assetPath, 'assets/images/zivybb_logo.png');
  });

  testWidgets('carries a semantic label by default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: ZivybbLogo())),
    );

    expect(tester.widget<Image>(find.byType(Image)).semanticLabel, 'Zivybb');
  });

  group('the plate behind the mark', () {
    /// The plate's fill and border, as actually rendered under [theme].
    (Color?, Color?) platePaint(WidgetTester tester) {
      final decoration =
          tester.widget<Container>(find.byType(Container)).decoration
              as BoxDecoration;
      return (decoration.color, decoration.border?.top.color);
    }

    Future<(Color?, Color?)> pumpUnder(
      WidgetTester tester,
      Brightness brightness,
    ) async {
      final theme = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF673AB7),
          brightness: brightness,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Center(child: ZivybbLogo(size: 40)),
        ),
      );
      // MaterialApp lerps between themes, so a single pump would still be
      // showing the previous one.
      await tester.pumpAndSettle();
      return platePaint(tester);
    }

    testWidgets('takes the surface and primary of the active theme', (
      tester,
    ) async {
      final light = ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF673AB7),
          brightness: Brightness.light,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: light,
          home: const Center(child: ZivybbLogo()),
        ),
      );

      final (fill, border) = platePaint(tester);
      expect(fill, light.colorScheme.surface);
      expect(border, light.colorScheme.primary);
    });

    testWidgets('follows the theme from light to dark', (tester) async {
      // The whole point of the plate: the mark is a bright gradient on
      // transparency, so it needs a backdrop that contrasts with whatever
      // coloured surface it has been dropped onto.
      final onLight = await pumpUnder(tester, Brightness.light);
      final onDark = await pumpUnder(tester, Brightness.dark);

      expect(
        onDark.$1,
        isNot(onLight.$1),
        reason: 'a fixed plate colour would defeat the dark theme',
      );
      expect(
        onLight.$1!.computeLuminance(),
        greaterThan(onDark.$1!.computeLuminance()),
      );
    });
  });
}
