import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/core/theme/app_theme.dart';

/// WCAG relative luminance.
double _luminance(Color color) {
  double channel(double value) => value <= 0.03928
      ? value / 12.92
      : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double _contrast(Color a, Color b) {
  final first = _luminance(a);
  final second = _luminance(b);
  return (math.max(first, second) + 0.05) / (math.min(first, second) + 0.05);
}

ThemeData _theme(Brightness brightness, AppThemeStyle style) => buildAppTheme(
  brightness: brightness,
  style: style,
  seedColor: const Color(0xFF673AB7),
);

void main() {
  group('chip labels carry their own colour', () {
    // Regression: ChipThemeData.labelStyle *replaces* the Material default
    // rather than merging with it, so a labelStyle without a colour left chip
    // text inheriting the ambient style — which rendered it invisible against
    // light backgrounds.
    test('every style and brightness resolves a label colour', () {
      for (final brightness in Brightness.values) {
        for (final style in AppThemeStyle.values) {
          final chipTheme = _theme(brightness, style).chipTheme;
          expect(
            chipTheme.labelStyle?.color,
            isNotNull,
            reason: '${style.label} / ${brightness.name} label',
          );
          expect(
            chipTheme.secondaryLabelStyle?.color,
            isNotNull,
            reason: '${style.label} / ${brightness.name} secondary label',
          );
        }
      }
    });

    test('label colour reads against the chip background', () {
      for (final brightness in Brightness.values) {
        for (final style in AppThemeStyle.values) {
          final theme = _theme(brightness, style);
          final label = theme.chipTheme.labelStyle!.color!;
          // The chip background is translucent, so composite it over the
          // surface the chip actually sits on before measuring.
          final background = Color.alphaBlend(
            theme.chipTheme.backgroundColor!,
            theme.colorScheme.surface,
          );
          expect(
            _contrast(label, background),
            greaterThanOrEqualTo(4.5),
            reason: '${style.label} / ${brightness.name}',
          );
        }
      }
    });

    test('label colour also reads when the chip is selected', () {
      for (final brightness in Brightness.values) {
        for (final style in AppThemeStyle.values) {
          final theme = _theme(brightness, style);
          final label = theme.chipTheme.labelStyle!.color!;
          final background = Color.alphaBlend(
            theme.chipTheme.selectedColor!,
            theme.colorScheme.surface,
          );
          expect(
            _contrast(label, background),
            greaterThanOrEqualTo(4.5),
            reason: '${style.label} / ${brightness.name}',
          );
        }
      }
    });
  });

  group('core scheme pairs stay legible', () {
    test('body text reads against the surface it sits on', () {
      for (final brightness in Brightness.values) {
        for (final style in AppThemeStyle.values) {
          final scheme = _theme(brightness, style).colorScheme;
          expect(
            _contrast(scheme.onSurface, scheme.surface),
            greaterThanOrEqualTo(4.5),
            reason: '${style.label} / ${brightness.name}',
          );
          expect(
            _contrast(scheme.onSurfaceVariant, scheme.surface),
            greaterThanOrEqualTo(4.5),
            reason: '${style.label} / ${brightness.name} (secondary text)',
          );
        }
      }
    });

    test('app-bar foreground reads against the gradient behind it', () {
      // GradientAppBar paints primary -> tertiary and writes in onPrimary, so
      // both ends of that ramp have to carry the text.
      for (final brightness in Brightness.values) {
        for (final style in AppThemeStyle.values) {
          final scheme = _theme(brightness, style).colorScheme;
          for (final background in [scheme.primary, scheme.tertiary]) {
            expect(
              _contrast(scheme.onPrimary, background),
              greaterThanOrEqualTo(3.0),
              reason: '${style.label} / ${brightness.name}',
            );
          }
        }
      }
    });
  });
}
