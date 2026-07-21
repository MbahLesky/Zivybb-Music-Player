import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/app_database.dart';
import '../models/app_settings.dart';

/// Single access point for app-wide settings (currently just the adaptive
/// dark mode preference; theming/equalizer fields land in later weeks).
class SettingsRepository {
  SettingsRepository({required this._database});

  final AppDatabase _database;

  Stream<AppSettings> watchSettings() {
    final query = _database.select(_database.settings)
      ..where((t) => t.id.equals(Settings.singletonId));
    return query.watchSingleOrNull().map(_toSettings);
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
    );
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(database: ref.watch(appDatabaseProvider)),
);
