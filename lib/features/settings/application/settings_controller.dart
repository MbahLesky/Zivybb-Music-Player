import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/adaptive_theme.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/repositories/settings_repository.dart';

final settingsStreamProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});

/// Forces [themeModeProvider] to re-evaluate periodically, so the adaptive
/// day/night schedule takes effect without requiring an app restart.
final _clockTickProvider = StreamProvider<void>((ref) {
  return Stream<void>.periodic(const Duration(minutes: 15));
});

/// The theme mode actually applied to the app: a manual override wins,
/// otherwise the adaptive time-of-day schedule (if enabled), otherwise
/// follows the system.
final themeModeProvider = Provider<ThemeMode>((ref) {
  ref.watch(_clockTickProvider);
  final settings =
      ref.watch(settingsStreamProvider).value ?? const AppSettings();

  final override = settings.manualThemeOverride;
  if (override != null) {
    return override == ThemeOverride.dark ? ThemeMode.dark : ThemeMode.light;
  }
  if (!settings.adaptiveDarkModeEnabled) return ThemeMode.system;
  return adaptiveThemeModeFor(DateTime.now());
});

/// Applies settings changes made from the Settings screen.
class SettingsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> setAdaptiveDarkModeEnabled(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(settingsRepositoryProvider)
          .setAdaptiveDarkModeEnabled(enabled),
    );
  }

  Future<void> setManualThemeOverride(ThemeOverride? override) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () =>
          ref.read(settingsRepositoryProvider).setManualThemeOverride(override),
    );
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AsyncValue<void>>(
      SettingsController.new,
    );
