import 'package:flutter/foundation.dart';

/// A user-forced light/dark choice that overrides the adaptive schedule.
enum ThemeOverride { light, dark }

const _unset = Object();

@immutable
class AppSettings {
  const AppSettings({
    this.adaptiveDarkModeEnabled = true,
    this.manualThemeOverride,
    this.themeSeedColorHex = '#673AB7',
    this.visualizerColorHex = '#673AB7',
    this.crossfadeEnabled = false,
    this.crossfadeDuration = const Duration(seconds: 3),
  });

  final bool adaptiveDarkModeEnabled;
  final ThemeOverride? manualThemeOverride;
  final String themeSeedColorHex;
  final String visualizerColorHex;
  final bool crossfadeEnabled;
  final Duration crossfadeDuration;

  /// Pass [manualThemeOverride] to change it, including to `null` (Auto).
  /// Omit it to leave the current value untouched.
  AppSettings copyWith({
    bool? adaptiveDarkModeEnabled,
    Object? manualThemeOverride = _unset,
    String? themeSeedColorHex,
    String? visualizerColorHex,
    bool? crossfadeEnabled,
    Duration? crossfadeDuration,
  }) {
    return AppSettings(
      adaptiveDarkModeEnabled:
          adaptiveDarkModeEnabled ?? this.adaptiveDarkModeEnabled,
      manualThemeOverride: identical(manualThemeOverride, _unset)
          ? this.manualThemeOverride
          : manualThemeOverride as ThemeOverride?,
      themeSeedColorHex: themeSeedColorHex ?? this.themeSeedColorHex,
      visualizerColorHex: visualizerColorHex ?? this.visualizerColorHex,
      crossfadeEnabled: crossfadeEnabled ?? this.crossfadeEnabled,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
    );
  }
}
