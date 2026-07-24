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
    this.currentEqualizerPresetId,
  });

  final bool adaptiveDarkModeEnabled;
  final ThemeOverride? manualThemeOverride;
  final String themeSeedColorHex;
  final String visualizerColorHex;
  final bool crossfadeEnabled;
  final Duration crossfadeDuration;
  final String? currentEqualizerPresetId;

  /// Pass [manualThemeOverride] or [currentEqualizerPresetId] to change
  /// them, including to `null`. Omit either to leave it untouched.
  AppSettings copyWith({
    bool? adaptiveDarkModeEnabled,
    Object? manualThemeOverride = _unset,
    String? themeSeedColorHex,
    String? visualizerColorHex,
    bool? crossfadeEnabled,
    Duration? crossfadeDuration,
    Object? currentEqualizerPresetId = _unset,
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
      currentEqualizerPresetId: identical(currentEqualizerPresetId, _unset)
          ? this.currentEqualizerPresetId
          : currentEqualizerPresetId as String?,
    );
  }
}
