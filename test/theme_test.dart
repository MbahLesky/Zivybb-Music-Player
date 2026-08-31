import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/core/theme/app_theme.dart';

void main() {
  test('buildAppTheme returns a glassy theme for each supported style', () {
    for (final style in AppThemeStyle.values) {
      final theme = buildAppTheme(
        brightness: Brightness.dark,
        style: style,
        seedColor: const Color(0xFF673AB7),
      );

      expect(theme.colorScheme.primary, isNot(Colors.transparent));
      expect(theme.cardTheme.shape, isNotNull);
      expect(theme.listTileTheme.shape, isNotNull);
      expect(theme.appBarTheme.backgroundColor, isNotNull);
    }
  });

  test('supports richer theme styles and compact list spacing', () {
    final theme = buildAppTheme(
      brightness: Brightness.dark,
      style: AppThemeStyle.glass,
      seedColor: const Color(0xFF673AB7),
    );
    final palette = theme.extension<AppThemePalette>();

    expect(
      AppThemeStyle.values.map((style) => style.label).toSet(),
      containsAll(<String>{
        'Aurora',
        'Midnight',
        'Sunset',
        'Mist',
        'Vivid',
        'Bloom',
        'Glass',
        'Minimal',
      }),
    );
    expect(
      theme.listTileTheme.contentPadding,
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
    expect(theme.cardTheme.margin, const EdgeInsets.symmetric(vertical: 4));
    expect(palette, isNotNull);
    expect(palette!.surfaceOpacity, greaterThan(0));
    expect(palette.blurSigma, greaterThan(0));
  });
}
