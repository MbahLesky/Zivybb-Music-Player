import 'package:flutter/foundation.dart';

import 'library_source_filter.dart';

/// A user-forced light/dark choice that overrides the adaptive schedule.
enum ThemeOverride { light, dark }

/// The wave visualizer's rendering style, user-selectable in Settings.
enum VisualizerStyle {
  bars,
  mirror,
  radial,
  bloom,
  particles,
  line,
  ribbon;

  String get label => switch (this) {
    VisualizerStyle.bars => 'Bars',
    VisualizerStyle.mirror => 'Mirror',
    VisualizerStyle.radial => 'Radial',
    VisualizerStyle.bloom => 'Bloom',
    VisualizerStyle.particles => 'Particles',
    VisualizerStyle.line => 'Line',
    VisualizerStyle.ribbon => 'Ribbon',
  };

  /// Circular styles need a squarer box than the wide, short bar styles.
  bool get isRadial =>
      this == VisualizerStyle.radial ||
      this == VisualizerStyle.bloom ||
      this == VisualizerStyle.particles;

  /// What this style turns into when it is asked to *be* the seek bar.
  ///
  /// The wide styles read left-to-right already, so they become the track
  /// itself. The circular ones become a ring around the artwork. Bloom is a
  /// single closed blob with no progress direction to read along, so there is
  /// nothing sensible for it to be — see [VisualizerSeekBarShape.unsupported].
  VisualizerSeekBarShape get seekBarShape => switch (this) {
    VisualizerStyle.bars ||
    VisualizerStyle.mirror ||
    VisualizerStyle.line ||
    VisualizerStyle.ribbon => VisualizerSeekBarShape.horizontal,
    VisualizerStyle.radial ||
    VisualizerStyle.particles => VisualizerSeekBarShape.circular,
    VisualizerStyle.bloom => VisualizerSeekBarShape.unsupported,
  };

  bool get supportsSeekBar =>
      seekBarShape != VisualizerSeekBarShape.unsupported;
}

/// How a style renders when it stands in for the seek bar.
enum VisualizerSeekBarShape {
  /// A track read left to right, in place of the slider.
  horizontal,

  /// A ring read clockwise from the top, filling the artwork slot with the
  /// artwork inside it.
  circular,

  /// Cannot be a seek bar; the option is offered but disabled.
  unsupported,
}

/// Where the visualizer is drawn on the Now Playing screen.
///
/// One choice rather than a set of switches, because the options are
/// genuinely exclusive: the visualizer can't both stand in for the artwork
/// and sit underneath it.
enum VisualizerPlacement {
  off,
  belowControls,
  underArtwork,
  replaceArtwork,
  seekBar;

  String get label => switch (this) {
    VisualizerPlacement.off => 'Off',
    VisualizerPlacement.belowControls => 'Below the controls',
    VisualizerPlacement.underArtwork => 'Under the artwork',
    VisualizerPlacement.replaceArtwork => 'In place of the artwork',
    VisualizerPlacement.seekBar => 'On the seek bar',
  };

  String get description => switch (this) {
    VisualizerPlacement.off => 'No visualizer on this screen',
    VisualizerPlacement.belowControls =>
      'A wide band under the transport buttons',
    VisualizerPlacement.underArtwork =>
      'A slim band between the artwork and the title',
    VisualizerPlacement.replaceArtwork =>
      'Fills the artwork slot — no album art shown',
    VisualizerPlacement.seekBar =>
      'The visualizer becomes the progress bar, and still scrubs',
  };

  bool get isVisible => this != VisualizerPlacement.off;

  /// Whether album art is drawn at all under this placement. Replacing the
  /// artwork means the art setting is moot while it is selected.
  bool get showsArtwork => this != VisualizerPlacement.replaceArtwork;
}

/// How the raw levels reaching the visualizer are shaped before they are
/// drawn — the difference between a row of bars that all look much the same
/// and one where quiet and loud are dramatically far apart.
///
/// Applied by `VisualizerMath.shape`, which is where the exact curve lives.
@immutable
class VisualizerTuning {
  const VisualizerTuning({
    this.sensitivity = 1.0,
    this.contrast = 1.0,
    this.floor = 0.12,
    this.responsiveness = 0.5,
    this.barCount = 40,
  });

  /// Overall gain. Above 1 pushes everything up (and more of it into the
  /// ceiling); below 1 leaves more headroom.
  final double sensitivity;

  /// Dynamic range: the exponent quiet levels are raised to. Above 1 drives
  /// quiet bands down while leaving loud ones alone, so the gap between low
  /// and high grows; below 1 flattens the picture out.
  final double contrast;

  /// The height bars collapse to at silence, so the visualizer still reads as
  /// a row of bars rather than vanishing. 0 lets them go all the way down.
  final double floor;

  /// How quickly the drawn level chases the real one, 0 (glassy and smooth)
  /// to 1 (twitchy and percussive). Drives [attack] and [decay].
  final double responsiveness;

  /// How many bars/points are drawn. Fewer reads chunkier, more reads finer.
  final int barCount;

  static const sensitivityRange = (0.4, 3.0);
  static const contrastRange = (0.4, 4.0);
  static const floorRange = (0.0, 0.35);
  static const responsivenessRange = (0.0, 1.0);
  static const barCountRange = (12, 96);

  /// Rise rate per frame. Always well above [decay]: a level meter only feels
  /// percussive if transients snap up and then bleed away.
  double get attack => _lerp(0.20, 0.92, responsiveness);

  /// Fall rate per frame.
  double get decay => _lerp(0.04, 0.32, responsiveness);

  /// The same values with every field forced into its documented range —
  /// applied when reading from the database, so a hand-edited or
  /// future-versioned row can't feed the painters nonsense.
  VisualizerTuning clamped() {
    return VisualizerTuning(
      sensitivity: _clamp(sensitivity, sensitivityRange),
      contrast: _clamp(contrast, contrastRange),
      floor: _clamp(floor, floorRange),
      responsiveness: _clamp(responsiveness, responsivenessRange),
      barCount: barCount.clamp(barCountRange.$1, barCountRange.$2),
    );
  }

  VisualizerTuning copyWith({
    double? sensitivity,
    double? contrast,
    double? floor,
    double? responsiveness,
    int? barCount,
  }) {
    return VisualizerTuning(
      sensitivity: sensitivity ?? this.sensitivity,
      contrast: contrast ?? this.contrast,
      floor: floor ?? this.floor,
      responsiveness: responsiveness ?? this.responsiveness,
      barCount: barCount ?? this.barCount,
    );
  }

  /// The preset these values came from, or null once the user has moved a
  /// slider away from every one of them. Used only to tick the active chip.
  VisualizerResponsePreset? get matchingPreset {
    for (final preset in VisualizerResponsePreset.values) {
      if (preset.tuning == this) return preset;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is VisualizerTuning &&
      // Compared with a tolerance because these round-trip through a slider
      // and a REAL column, and an exact match is what decides whether a
      // preset chip shows as selected.
      (other.sensitivity - sensitivity).abs() < 1e-6 &&
      (other.contrast - contrast).abs() < 1e-6 &&
      (other.floor - floor).abs() < 1e-6 &&
      (other.responsiveness - responsiveness).abs() < 1e-6 &&
      other.barCount == barCount;

  @override
  int get hashCode => Object.hash(
    sensitivity.toStringAsFixed(3),
    contrast.toStringAsFixed(3),
    floor.toStringAsFixed(3),
    responsiveness.toStringAsFixed(3),
    barCount,
  );

  static double _lerp(double from, double to, double t) =>
      from + (to - from) * t.clamp(0.0, 1.0);

  static double _clamp(double value, (double, double) range) =>
      value.isFinite ? value.clamp(range.$1, range.$2) : range.$1;
}

/// One-tap bundles of [VisualizerTuning], from barely-there to wildly
/// exaggerated. The sliders stay available underneath for anything between.
enum VisualizerResponsePreset {
  subtle(
    'Subtle',
    'Gentle movement, bars stay close in height',
    VisualizerTuning(
      sensitivity: 0.9,
      contrast: 0.6,
      floor: 0.22,
      responsiveness: 0.25,
      barCount: 32,
    ),
  ),
  balanced(
    'Balanced',
    'The default — even response across the spectrum',
    VisualizerTuning(),
  ),
  punchy(
    'Punchy',
    'Quiet bands drop away so peaks stand out',
    VisualizerTuning(
      sensitivity: 1.3,
      contrast: 1.9,
      floor: 0.05,
      responsiveness: 0.78,
      barCount: 48,
    ),
  ),
  extreme(
    'Extreme',
    'Maximum contrast — near-silence flattens to nothing',
    VisualizerTuning(
      sensitivity: 1.8,
      contrast: 3.2,
      floor: 0.0,
      responsiveness: 0.95,
      barCount: 64,
    ),
  );

  const VisualizerResponsePreset(this.label, this.description, this.tuning);

  final String label;
  final String description;
  final VisualizerTuning tuning;
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
    this.visualizerPlacement = VisualizerPlacement.belowControls,
    this.visualizerAsArtworkFallback = false,
    this.visualizerTuning = const VisualizerTuning(),
    this.seekStep = const Duration(seconds: 10),
    this.includeVideos = false,
    this.realVisualizerEnabled = false,
    this.librarySourceFilter = const LibrarySourceFilter(),
    this.compactNowPlaying = false,
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

  /// Where the visualizer sits on Now Playing. Replaces the old
  /// show/hide boolean, which is now just [VisualizerPlacement.off].
  final VisualizerPlacement visualizerPlacement;

  /// Draw the visualizer in the artwork slot for songs that have no artwork,
  /// instead of the generic music-note placeholder.
  final bool visualizerAsArtworkFallback;

  /// How the levels are shaped before being drawn.
  final VisualizerTuning visualizerTuning;

  /// How far Now Playing's seek-back/forward buttons jump.
  final Duration seekStep;

  /// Whether the library scan also picks up video files, played as audio.
  final bool includeVideos;

  /// Drive the visualizer from the real audio signal instead of the
  /// simulated waveform. Opt-in: it needs the RECORD_AUDIO permission.
  final bool realVisualizerEnabled;

  /// Which of the device's audio files count as music — see [LibrarySourceFilter].
  final LibrarySourceFilter librarySourceFilter;

  /// Strip Now Playing back to artwork, title and the three transport
  /// buttons. Everything the compact layout drops — shuffle, repeat, like,
  /// save to playlist — moves into the "more" sheet rather than going away.
  final bool compactNowPlaying;

  /// The placement actually in force.
  ///
  /// [VisualizerPlacement.seekBar] needs a style that can be read as a track;
  /// bloom cannot, so a saved seek-bar choice degrades to the default rather
  /// than leaving the screen with no progress bar at all. Settings disables
  /// the option for that style, but the stored value outlives the style
  /// choice — someone can pick the seek bar and then switch to bloom.
  VisualizerPlacement get effectiveVisualizerPlacement {
    if (visualizerPlacement == VisualizerPlacement.seekBar &&
        !visualizerStyle.supportsSeekBar) {
      return VisualizerPlacement.belowControls;
    }
    return visualizerPlacement;
  }

  /// Whether the visualizer is standing in for the progress bar right now.
  bool get visualizerIsSeekBar =>
      effectiveVisualizerPlacement == VisualizerPlacement.seekBar;

  /// Whether that stand-in is the ring around the artwork rather than a track
  /// under the title — which is what decides whether the artwork slot is
  /// given over to it and whether the linear bar is drawn at all.
  bool get visualizerIsCircularSeekBar =>
      visualizerIsSeekBar &&
      visualizerStyle.seekBarShape == VisualizerSeekBarShape.circular;

  /// Whether the artwork slot on Now Playing shows a visualizer for [song]
  /// rather than album art, either because the user asked for that
  /// everywhere or because this particular song has no art to show.
  ///
  /// The circular seek bar is the exception: it fills the artwork slot *and*
  /// shows the artwork, inside the ring.
  bool visualizerFillsArtworkSlot({required bool songHasArtwork}) {
    if (visualizerIsCircularSeekBar) return false;
    if (effectiveVisualizerPlacement == VisualizerPlacement.replaceArtwork) {
      return true;
    }
    return visualizerAsArtworkFallback && !songHasArtwork;
  }

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
    VisualizerPlacement? visualizerPlacement,
    bool? visualizerAsArtworkFallback,
    VisualizerTuning? visualizerTuning,
    Duration? seekStep,
    bool? includeVideos,
    bool? realVisualizerEnabled,
    LibrarySourceFilter? librarySourceFilter,
    bool? compactNowPlaying,
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
      visualizerPlacement: visualizerPlacement ?? this.visualizerPlacement,
      visualizerAsArtworkFallback:
          visualizerAsArtworkFallback ?? this.visualizerAsArtworkFallback,
      visualizerTuning: visualizerTuning ?? this.visualizerTuning,
      seekStep: seekStep ?? this.seekStep,
      includeVideos: includeVideos ?? this.includeVideos,
      realVisualizerEnabled:
          realVisualizerEnabled ?? this.realVisualizerEnabled,
      librarySourceFilter: librarySourceFilter ?? this.librarySourceFilter,
      compactNowPlaying: compactNowPlaying ?? this.compactNowPlaying,
    );
  }
}
