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
}
