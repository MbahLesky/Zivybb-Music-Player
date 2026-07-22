import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/app_database.dart';
import '../models/app_settings.dart';

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
    );
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(database: ref.watch(appDatabaseProvider)),
);
