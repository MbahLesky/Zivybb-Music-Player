import 'package:flutter/foundation.dart';

/// A user-forced light/dark choice that overrides the adaptive schedule.
enum ThemeOverride { light, dark }

/// The wave visualizer's rendering style, user-selectable in Settings.
enum VisualizerStyle {
  bars,
  radial,
  particles,
  line;

  String get label => switch (this) {
    VisualizerStyle.bars => 'Bars',
    VisualizerStyle.radial => 'Radial',
    VisualizerStyle.particles => 'Particles',
    VisualizerStyle.line => 'Line',
  };
}

const _unset = Object();

@immutable
class AppSettings {
  const AppSettings({
    this.adaptiveDarkModeEnabled = true,
    this.manualThemeOverride,
    this.themeSeedColorHex = '#673AB7',
    this.visualizerColorHex = '#673AB7',
    this.themeStyleName = 'aurora',
    this.crossfadeEnabled = false,
    this.crossfadeDuration = const Duration(seconds: 15),
    this.currentEqualizerPresetId,
    this.visualizerStyle = VisualizerStyle.bars,
    this.showAlbumArtInMiniPlayer = true,
    this.showVisualizerInMiniPlayer = false,
    this.showAlbumArtInNowPlaying = true,
    this.showVisualizerInNowPlaying = true,
    this.seekStep = const Duration(seconds: 10),
    this.includeVideos = false,
    this.realtimeVisualizerEnabled = false,
  });

  final bool adaptiveDarkModeEnabled;
  final ThemeOverride? manualThemeOverride;
  final String themeSeedColorHex;
  final String visualizerColorHex;
  final String themeStyleName;
  final bool crossfadeEnabled;
  final Duration crossfadeDuration;
  final String? currentEqualizerPresetId;
  final VisualizerStyle visualizerStyle;
  final bool showAlbumArtInMiniPlayer;
  final bool showVisualizerInMiniPlayer;
  final bool showAlbumArtInNowPlaying;
  final bool showVisualizerInNowPlaying;

  /// How far Now Playing's seek-back/forward buttons jump.
  final Duration seekStep;

  /// Whether the library scan also picks up video files, played as audio.
  final bool includeVideos;

  /// Whether the visualizer reacts to the real audio signal rather than a
  /// simulated waveform.
  final bool realtimeVisualizerEnabled;

  /// Pass [manualThemeOverride] or [currentEqualizerPresetId] to change
  /// them, including to `null`. Omit either to leave it untouched.
  AppSettings copyWith({
    bool? adaptiveDarkModeEnabled,
    Object? manualThemeOverride = _unset,
    String? themeSeedColorHex,
    String? visualizerColorHex,
    String? themeStyleName,
    bool? crossfadeEnabled,
    Duration? crossfadeDuration,
    Object? currentEqualizerPresetId = _unset,
    VisualizerStyle? visualizerStyle,
    bool? showAlbumArtInMiniPlayer,
    bool? showVisualizerInMiniPlayer,
    bool? showAlbumArtInNowPlaying,
    bool? showVisualizerInNowPlaying,
    Duration? seekStep,
    bool? includeVideos,
    bool? realtimeVisualizerEnabled,
  }) {
    return AppSettings(
      adaptiveDarkModeEnabled:
          adaptiveDarkModeEnabled ?? this.adaptiveDarkModeEnabled,
      manualThemeOverride: identical(manualThemeOverride, _unset)
          ? this.manualThemeOverride
          : manualThemeOverride as ThemeOverride?,
      themeSeedColorHex: themeSeedColorHex ?? this.themeSeedColorHex,
      visualizerColorHex: visualizerColorHex ?? this.visualizerColorHex,
      themeStyleName: themeStyleName ?? this.themeStyleName,
      crossfadeEnabled: crossfadeEnabled ?? this.crossfadeEnabled,
      crossfadeDuration: crossfadeDuration ?? this.crossfadeDuration,
      currentEqualizerPresetId: identical(currentEqualizerPresetId, _unset)
          ? this.currentEqualizerPresetId
          : currentEqualizerPresetId as String?,
      visualizerStyle: visualizerStyle ?? this.visualizerStyle,
      showAlbumArtInMiniPlayer:
          showAlbumArtInMiniPlayer ?? this.showAlbumArtInMiniPlayer,
      showVisualizerInMiniPlayer:
          showVisualizerInMiniPlayer ?? this.showVisualizerInMiniPlayer,
      showAlbumArtInNowPlaying:
          showAlbumArtInNowPlaying ?? this.showAlbumArtInNowPlaying,
      showVisualizerInNowPlaying:
          showVisualizerInNowPlaying ?? this.showVisualizerInNowPlaying,
      seekStep: seekStep ?? this.seekStep,
      includeVideos: includeVideos ?? this.includeVideos,
      realtimeVisualizerEnabled:
          realtimeVisualizerEnabled ?? this.realtimeVisualizerEnabled,
    );
  }
}
