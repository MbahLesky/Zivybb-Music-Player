import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/app_database.dart';
import '../models/equalizer_preset.dart';

/// Built-in presets, defined over a 5-band bass-to-treble reference curve
/// (SRS F-1.6). Seeded once; the user can only pick among these for V1.
const _defaultPresets = [
  EqualizerPreset(id: 'flat', name: 'Flat', bandGains: [0, 0, 0, 0, 0]),
  EqualizerPreset(
    id: 'bass_boost',
    name: 'Bass Boost',
    bandGains: [6, 4, 0, -2, -2],
  ),
  EqualizerPreset(
    id: 'treble_boost',
    name: 'Treble Boost',
    bandGains: [-2, -1, 0, 4, 6],
  ),
  EqualizerPreset(
    id: 'vocal_boost',
    name: 'Vocal Boost',
    bandGains: [-2, 0, 4, 3, 0],
  ),
  EqualizerPreset(
    id: 'electronic',
    name: 'Electronic',
    bandGains: [4, 2, -2, 2, 4],
  ),
];

/// Single access point for equalizer presets.
class EqualizerPresetRepository {
  EqualizerPresetRepository({required this._database});

  final AppDatabase _database;

  /// Inserts the built-in presets if the table is empty. Safe to call on
  /// every app start.
  Future<void> ensureSeeded() async {
    final existing = await _database.select(_database.equalizerPresets).get();
    if (existing.isNotEmpty) return;

    await _database.batch((batch) {
      batch.insertAll(
        _database.equalizerPresets,
        _defaultPresets.map(
          (preset) => EqualizerPresetsCompanion.insert(
            id: preset.id,
            name: preset.name,
            bandLevelsJson: jsonEncode(preset.bandGains),
          ),
        ),
      );
    });
  }

  Stream<List<EqualizerPreset>> watchPresets() {
    return _database
        .select(_database.equalizerPresets)
        .watch()
        .map(
          (rows) => rows.map(EqualizerPreset.fromRow).toList(growable: false),
        );
  }
}

final equalizerPresetRepositoryProvider = Provider<EqualizerPresetRepository>(
  (ref) => EqualizerPresetRepository(database: ref.watch(appDatabaseProvider)),
);
