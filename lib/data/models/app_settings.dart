import 'package:flutter/foundation.dart';

/// A user-forced light/dark choice that overrides the adaptive schedule.
enum ThemeOverride { light, dark }

const _unset = Object();

@immutable
class AppSettings {
  const AppSettings({
    this.adaptiveDarkModeEnabled = true,
    this.manualThemeOverride,
  });

  final bool adaptiveDarkModeEnabled;
  final ThemeOverride? manualThemeOverride;

  /// Pass [manualThemeOverride] to change it, including to `null` (Auto).
  /// Omit it to leave the current value untouched.
  AppSettings copyWith({
    bool? adaptiveDarkModeEnabled,
    Object? manualThemeOverride = _unset,
  }) {
    return AppSettings(
      adaptiveDarkModeEnabled:
          adaptiveDarkModeEnabled ?? this.adaptiveDarkModeEnabled,
      manualThemeOverride: identical(manualThemeOverride, _unset)
          ? this.manualThemeOverride
          : manualThemeOverride as ThemeOverride?,
    );
  }
}
