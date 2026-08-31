import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/app_database.dart';
import '../models/app_settings.dart';
import '../models/library_source_filter.dart';

/// Single access point for app-wide settings: adaptive dark mode, theme and
/// visualizer color, crossfade, and the selected equalizer preset.
class SettingsRepository {
  SettingsRepository({required this._database});

  final AppDatabase _database;

  Stream<AppSettings> watchSettings() {
    final query = _database.select(_database.settings)
      ..where((t) => t.id.equals(Settings.singletonId));
    return query.watchSingleOrNull().map(_toSettings);
  }

  /// One-off (non-reactive) fetch, used by `BackupRepository`.
  Future<AppSettings> currentSettings() async {
    final row = await (_database.select(
      _database.settings,
    )..where((t) => t.id.equals(Settings.singletonId))).getSingleOrNull();
    return _toSettings(row);
  }

  Future<void> setAdaptiveDarkModeEnabled(bool enabled) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        adaptiveDarkModeEnabled: Value(enabled),
      ),
      onConflict: (_) =>
          SettingsCompanion(adaptiveDarkModeEnabled: Value(enabled)),
    );
  }

  Future<void> setManualThemeOverride(ThemeOverride? override) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        manualThemeOverride: Value(override?.name),
      ),
      onConflict: (_) =>
          SettingsCompanion(manualThemeOverride: Value(override?.name)),
    );
  }

  Future<void> setThemeSeedColor(String colorHex) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        themeSeedColorHex: Value(colorHex),
      ),
      onConflict: (_) => SettingsCompanion(themeSeedColorHex: Value(colorHex)),
    );
  }

  Future<void> setVisualizerColor(String colorHex) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        visualizerColorHex: Value(colorHex),
      ),
      onConflict: (_) => SettingsCompanion(visualizerColorHex: Value(colorHex)),
    );
  }

  Future<void> setCrossfadeEnabled(bool enabled) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        crossfadeEnabled: Value(enabled),
      ),
      onConflict: (_) => SettingsCompanion(crossfadeEnabled: Value(enabled)),
    );
  }

  Future<void> setCrossfadeDuration(Duration duration) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        crossfadeDurationMs: Value(duration.inMilliseconds),
      ),
      onConflict: (_) => SettingsCompanion(
        crossfadeDurationMs: Value(duration.inMilliseconds),
      ),
    );
  }

  Future<void> setEqualizerPreset(String? presetId) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        currentEqualizerPresetId: Value(presetId),
      ),
      onConflict: (_) =>
          SettingsCompanion(currentEqualizerPresetId: Value(presetId)),
    );
  }

  Future<void> setVisualizerStyle(VisualizerStyle style) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        visualizerStyle: Value(style.name),
      ),
      onConflict: (_) => SettingsCompanion(visualizerStyle: Value(style.name)),
    );
  }

  Future<void> setShowAlbumArtInMiniPlayer(bool enabled) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        showAlbumArtInMiniPlayer: Value(enabled),
      ),
      onConflict: (_) =>
          SettingsCompanion(showAlbumArtInMiniPlayer: Value(enabled)),
    );
  }

  Future<void> setShowVisualizerInMiniPlayer(bool enabled) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        showVisualizerInMiniPlayer: Value(enabled),
      ),
      onConflict: (_) =>
          SettingsCompanion(showVisualizerInMiniPlayer: Value(enabled)),
    );
  }

  Future<void> setShowAlbumArtInNowPlaying(bool enabled) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        showAlbumArtInNowPlaying: Value(enabled),
      ),
      onConflict: (_) =>
          SettingsCompanion(showAlbumArtInNowPlaying: Value(enabled)),
    );
  }

  Future<void> setVisualizerPlacement(VisualizerPlacement placement) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        visualizerPlacement: Value(placement.name),
      ),
      onConflict: (_) =>
          SettingsCompanion(visualizerPlacement: Value(placement.name)),
    );
  }

  Future<void> setVisualizerAsArtworkFallback(bool enabled) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        visualizerAsArtworkFallback: Value(enabled),
      ),
      onConflict: (_) =>
          SettingsCompanion(visualizerAsArtworkFallback: Value(enabled)),
    );
  }

  /// Writes all five tuning values at once. They are always set together —
  /// picking a preset changes every one — and one row write keeps the
  /// visualizer from restyling itself five times in a row.
  Future<void> setVisualizerTuning(VisualizerTuning tuning) {
    final safe = tuning.clamped();
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        visualizerSensitivity: Value(safe.sensitivity),
        visualizerContrast: Value(safe.contrast),
        visualizerFloor: Value(safe.floor),
        visualizerResponsiveness: Value(safe.responsiveness),
        visualizerBarCount: Value(safe.barCount),
      ),
      onConflict: (_) => SettingsCompanion(
        visualizerSensitivity: Value(safe.sensitivity),
        visualizerContrast: Value(safe.contrast),
        visualizerFloor: Value(safe.floor),
        visualizerResponsiveness: Value(safe.responsiveness),
        visualizerBarCount: Value(safe.barCount),
      ),
    );
  }

  Future<void> setSeekStep(Duration step) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        seekStepSeconds: Value(step.inSeconds),
      ),
      onConflict: (_) =>
          SettingsCompanion(seekStepSeconds: Value(step.inSeconds)),
    );
  }

  Future<void> setIncludeVideos(bool enabled) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        includeVideos: Value(enabled),
      ),
      onConflict: (_) => SettingsCompanion(includeVideos: Value(enabled)),
    );
  }

  Future<void> setRealVisualizerEnabled(bool enabled) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        realVisualizerEnabled: Value(enabled),
      ),
      onConflict: (_) =>
          SettingsCompanion(realVisualizerEnabled: Value(enabled)),
    );
  }

  Future<void> setCompactNowPlaying(bool enabled) {
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        compactNowPlaying: Value(enabled),
      ),
      onConflict: (_) => SettingsCompanion(compactNowPlaying: Value(enabled)),
    );
  }

  /// Writes the whole [LibrarySourceFilter] at once. Its three parts are always
  /// changed together from the Library Sources screen, and each write kicks
  /// off a rescan — one write means one rescan.
  Future<void> setLibrarySourceFilter(LibrarySourceFilter filter) {
    final seconds = filter.minimumDuration.inSeconds;
    final overrides = filter.overridesToJson();
    return _upsert(
      SettingsCompanion.insert(
        id: Settings.singletonId,
        autoExcludeNonMusicFolders: Value(filter.autoExcludeNonMusicFolders),
        minimumTrackSeconds: Value(seconds),
        libraryFolderOverridesJson: Value(overrides),
      ),
      onConflict: (_) => SettingsCompanion(
        autoExcludeNonMusicFolders: Value(filter.autoExcludeNonMusicFolders),
        minimumTrackSeconds: Value(seconds),
        libraryFolderOverridesJson: Value(overrides),
      ),
    );
  }

  /// Writes every setting in one row write, used by `BackupRepository` on
  /// restore.
  ///
  /// Driving the individual setters instead would emit twenty-odd settings
  /// updates back to back, each one restyling the whole app and restarting
  /// the visualizer on its way to the state the backup actually describes.
  ///
  /// [settings.currentEqualizerPresetId] must name a preset that exists —
  /// the column is a foreign key, so an unknown id fails the write.
  Future<void> replaceAll(AppSettings settings) {
    final tuning = settings.visualizerTuning.clamped();
    final row = SettingsCompanion(
      id: const Value(Settings.singletonId),
      adaptiveDarkModeEnabled: Value(settings.adaptiveDarkModeEnabled),
      manualThemeOverride: Value(settings.manualThemeOverride?.name),
      themeSeedColorHex: Value(settings.themeSeedColorHex),
      visualizerColorHex: Value(settings.visualizerColorHex),
      crossfadeEnabled: Value(settings.crossfadeEnabled),
      crossfadeDurationMs: Value(settings.crossfadeDuration.inMilliseconds),
      currentEqualizerPresetId: Value(settings.currentEqualizerPresetId),
      visualizerStyle: Value(settings.visualizerStyle.name),
      showAlbumArtInMiniPlayer: Value(settings.showAlbumArtInMiniPlayer),
      showVisualizerInMiniPlayer: Value(settings.showVisualizerInMiniPlayer),
      showAlbumArtInNowPlaying: Value(settings.showAlbumArtInNowPlaying),
      visualizerPlacement: Value(settings.visualizerPlacement.name),
      visualizerAsArtworkFallback: Value(settings.visualizerAsArtworkFallback),
      visualizerSensitivity: Value(tuning.sensitivity),
      visualizerContrast: Value(tuning.contrast),
      visualizerFloor: Value(tuning.floor),
      visualizerResponsiveness: Value(tuning.responsiveness),
      visualizerBarCount: Value(tuning.barCount),
      seekStepSeconds: Value(settings.seekStep.inSeconds),
      includeVideos: Value(settings.includeVideos),
      realVisualizerEnabled: Value(settings.realVisualizerEnabled),
      autoExcludeNonMusicFolders: Value(
        settings.librarySourceFilter.autoExcludeNonMusicFolders,
      ),
      minimumTrackSeconds: Value(
        settings.librarySourceFilter.minimumDuration.inSeconds,
      ),
      libraryFolderOverridesJson: Value(
        settings.librarySourceFilter.overridesToJson(),
      ),
      compactNowPlaying: Value(settings.compactNowPlaying),
    );
    return _upsert(row, onConflict: (_) => row);
  }

  /// Reads a stored [VisualizerPlacement] name, falling back to the default
  /// rather than throwing. The v13 migration seeds this column from a
  /// boolean, so any row it missed would otherwise take the whole settings
  /// stream down with it.
  static VisualizerPlacement _placementFrom(String name) {
    for (final placement in VisualizerPlacement.values) {
      if (placement.name == name) return placement;
    }
    return VisualizerPlacement.belowControls;
  }

  Future<void> _upsert(
    SettingsCompanion insertable, {
    required Insertable<SettingsRow> Function($SettingsTable old) onConflict,
  }) {
    return _database
        .into(_database.settings)
        .insert(insertable, onConflict: DoUpdate(onConflict));
  }

  AppSettings _toSettings(SettingsRow? row) {
    if (row == null) return const AppSettings();
    return AppSettings(
      adaptiveDarkModeEnabled: row.adaptiveDarkModeEnabled,
      manualThemeOverride: row.manualThemeOverride == null
          ? null
          : ThemeOverride.values.byName(row.manualThemeOverride!),
      themeSeedColorHex: row.themeSeedColorHex,
      visualizerColorHex: row.visualizerColorHex,
      crossfadeEnabled: row.crossfadeEnabled,
      crossfadeDuration: Duration(milliseconds: row.crossfadeDurationMs),
      currentEqualizerPresetId: row.currentEqualizerPresetId,
      visualizerStyle: VisualizerStyle.values.byName(row.visualizerStyle),
      showAlbumArtInMiniPlayer: row.showAlbumArtInMiniPlayer,
      showVisualizerInMiniPlayer: row.showVisualizerInMiniPlayer,
      showAlbumArtInNowPlaying: row.showAlbumArtInNowPlaying,
      visualizerPlacement: _placementFrom(row.visualizerPlacement),
      visualizerAsArtworkFallback: row.visualizerAsArtworkFallback,
      visualizerTuning: VisualizerTuning(
        sensitivity: row.visualizerSensitivity,
        contrast: row.visualizerContrast,
        floor: row.visualizerFloor,
        responsiveness: row.visualizerResponsiveness,
        barCount: row.visualizerBarCount,
      ).clamped(),
      seekStep: Duration(seconds: row.seekStepSeconds),
      includeVideos: row.includeVideos,
      realVisualizerEnabled: row.realVisualizerEnabled,
      librarySourceFilter: _librarySourceFilterFrom(row),
      compactNowPlaying: row.compactNowPlaying,
    );
  }

  static LibrarySourceFilter _librarySourceFilterFrom(SettingsRow row) {
    final overrides = LibrarySourceFilter.overridesFromJson(
      row.libraryFolderOverridesJson,
    );
    return LibrarySourceFilter(
      autoExcludeNonMusicFolders: row.autoExcludeNonMusicFolders,
      // Clamped rather than trusted: a negative value would mean "shorter
      // than nothing", and an hour-long floor would empty the library.
      minimumDuration: Duration(seconds: row.minimumTrackSeconds.clamp(0, 600)),
      includedFolders: overrides.included,
      excludedFolders: overrides.excluded,
    );
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(database: ref.watch(appDatabaseProvider)),
);
