import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/adaptive_theme.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_hex.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/library_source_filter.dart';
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

final appThemeStyleProvider = StateProvider<AppThemeStyle>(
  (ref) => AppThemeStyle.aurora,
);

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

/// How the visualizer's levels are shaped before they are drawn.
///
/// Not auto-disposing, unlike its neighbours: the visualizer reads this from
/// inside a ticker callback with `ref.read`, which does not keep a provider
/// alive, so an auto-disposing one would be torn down and rebuilt on every
/// frame that nothing else happened to be watching it.
final visualizerTuningProvider = Provider<VisualizerTuning>((ref) {
  final settings =
      ref.watch(settingsStreamProvider).value ?? const AppSettings();
  return settings.visualizerTuning;
});

/// Where the visualizer is drawn on the Now Playing screen.
final visualizerPlacementProvider = Provider.autoDispose<VisualizerPlacement>((
  ref,
) {
  final settings =
      ref.watch(settingsStreamProvider).value ?? const AppSettings();
  return settings.visualizerPlacement;
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

  /// Turns real-audio visualization on or off.
  ///
  /// Enabling it requires RECORD_AUDIO — Android gates the `Visualizer`
  /// effect behind that permission because it observes the output mix, even
  /// though Zivybb never touches the microphone. If the user declines, the
  /// setting stays off rather than silently persisting a preference that
  /// can't take effect; the caller can tell from the returned value.
  Future<bool> setRealVisualizerEnabled(bool enabled) async {
    if (enabled) {
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        state = const AsyncValue.data(null);
        return false;
      }
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(settingsRepositoryProvider)
          .setRealVisualizerEnabled(enabled),
    );
    return enabled;
  }

  Future<void> setVisualizerPlacement(VisualizerPlacement placement) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(settingsRepositoryProvider)
          .setVisualizerPlacement(placement),
    );
  }

  Future<void> setVisualizerAsArtworkFallback(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref
          .read(settingsRepositoryProvider)
          .setVisualizerAsArtworkFallback(enabled),
    );
  }

  Future<void> setVisualizerTuning(VisualizerTuning tuning) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setVisualizerTuning(tuning),
    );
  }

  Future<void> setSeekStep(Duration step) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setSeekStep(step),
    );
  }

  Future<void> setIncludeVideos(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setIncludeVideos(enabled),
    );
  }

  Future<void> setCompactNowPlaying(bool enabled) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setCompactNowPlaying(enabled),
    );
  }

  Future<void> setLibrarySourceFilter(LibrarySourceFilter filter) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(settingsRepositoryProvider).setLibrarySourceFilter(filter),
    );
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, AsyncValue<void>>(
      SettingsController.new,
    );
