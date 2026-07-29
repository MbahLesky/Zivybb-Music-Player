import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/adaptive_theme.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_hex.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/repositories/settings_repository.dart';

final settingsStreamProvider = StreamProvider<AppSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).watchSettings();
});

/// The theme mode actually applied to the app: a manual override wins,
/// otherwise the adaptive time-of-day schedule (if enabled), otherwise
/// follows the system.
final themeModeProvider = Provider.autoDispose<ThemeMode>((ref) {
  final settings =
      ref.watch(settingsStreamProvider).value ?? const AppSettings();

  final override = settings.manualThemeOverride;
  if (override != null) {
    return override == ThemeOverride.dark ? ThemeMode.dark : ThemeMode.light;
  }
  if (!settings.adaptiveDarkModeEnabled) return ThemeMode.system;
  return adaptiveThemeModeFor(DateTime.now());
});

/// The app's color-scheme seed, derived from the user's theme color choice.
final themeSeedColorProvider = Provider.autoDispose<Color>((ref) {
  final settings =
      ref.watch(settingsStreamProvider).value ?? const AppSettings();
  return colorFromHex(settings.themeSeedColorHex);
});

final appThemeStyleProvider = StateProvider<AppThemeStyle>((ref) => AppThemeStyle.aurora);

/// The wave visualizer's color, derived from the user's choice.
final visualizerColorProvider = Provider.autoDispose<Color>((ref) {
  final settings =
      ref.watch(settingsStreamProvider).value ?? const AppSettings();
  return colorFromHex(settings.visualizerColorHex);
});

/// The wave visualizer's rendering style, derived from the user's choice.
final visualizerStyleProvider = Provider.autoDispose<VisualizerStyle>((ref) {
  final settings =
      ref.watch(settingsStreamProvider).value ?? const AppSettings();
  return settings.visualizerStyle;
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

  Future<void> setThemeSeedColor(Color color) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(settingsRepositoryProvider)
          .setThemeSeedColor(colorToHex(color)),
    );
  }

  Future<void> setVisualizerColor(Color color) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(settingsRepositoryProvider)
          .setVisualizerColor(colorToHex(color)),
    );
  }

  Future<void> setAppThemeStyle(AppThemeStyle style) async {
    ref.read(appThemeStyleProvider.notifier).state = style;
    state = const AsyncValue.data(null);
  }

  Future<void> setCrossfadeEnabled(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setCrossfadeEnabled(enabled),
    );
  }

  Future<void> setCrossfadeDuration(Duration duration) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setCrossfadeDuration(duration),
    );
  }

  Future<void> setEqualizerPreset(String? presetId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setEqualizerPreset(presetId),
    );
  }

  Future<void> setVisualizerStyle(VisualizerStyle style) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setVisualizerStyle(style),
    );
  }

  Future<void> setShowAlbumArtInMiniPlayer(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(settingsRepositoryProvider)
          .setShowAlbumArtInMiniPlayer(enabled),
    );
  }

  Future<void> setShowVisualizerInMiniPlayer(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(settingsRepositoryProvider)
          .setShowVisualizerInMiniPlayer(enabled),
    );
  }

  Future<void> setShowAlbumArtInNowPlaying(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(settingsRepositoryProvider)
          .setShowAlbumArtInNowPlaying(enabled),
    );
  }

  Future<void> setShowVisualizerInNowPlaying(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(settingsRepositoryProvider)
          .setShowVisualizerInNowPlaying(enabled),
    );
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AsyncValue<void>>(
      SettingsController.new,
    );
