import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../datasources/app_database.dart';
import '../models/equalizer_preset.dart';

/// Nominal center frequencies of the 5-band reference curve, for labelling
/// the custom equalizer's sliders. The device's own bands are mapped onto
/// this curve at apply-time (see `AudioPlayerService.applyEqualizerBandGains`),
/// so these are indicative rather than exact.
const equalizerBandLabels = ['60Hz', '230Hz', '910Hz', '3.6kHz', '14kHz'];

/// Widest gain the custom equalizer offers, in decibels. Clamped again to
/// the device's real range when applied.
const equalizerMaxGainDb = 12.0;

/// The preset backing the user's hand-tuned curve. Unlike the built-ins it
/// is rewritten in place whenever a slider moves.
const customEqualizerPresetId = 'custom';

/// Built-in presets, defined over a 5-band bass-to-treble reference curve
/// (SRS F-1.6), plus the editable [customEqualizerPresetId] curve.
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
  EqualizerPreset(
    id: customEqualizerPresetId,
    name: 'Custom',
    bandGains: [0, 0, 0, 0, 0],
  ),
];

/// Single access point for equalizer presets.
class EqualizerPresetRepository {
  EqualizerPresetRepository({required this._database});

  final AppDatabase _database;

  /// Inserts any built-in preset that isn't stored yet, leaving existing
  /// rows (including the user's tuned [customEqualizerPresetId] curve)
  /// untouched. Safe to call on every app start — and unlike a whole-table
  /// emptiness check, it also backfills presets added in later versions.
  Future<void> ensureSeeded() async {
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
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  /// Overwrites a preset's curve — used by the custom equalizer's sliders.
  Future<void> updateBandGains(String presetId, List<double> bandGains) {
    return (_database.update(
      _database.equalizerPresets,
    )..where((t) => t.id.equals(presetId))).write(
      EqualizerPresetsCompanion(bandLevelsJson: Value(jsonEncode(bandGains))),
    );
  }

  /// Writes a preset's curve, inserting the row when it isn't there yet.
  ///
  /// [updateBandGains] silently writes nothing against a missing row, which
  /// a restore onto a fresh install would hit: [ensureSeeded] runs when the
  /// Library screen comes up, and a backup can be restored before that. Only
  /// the gains are overwritten on conflict — preset names come from code, so
  /// a name carried in an old backup shouldn't win over the current one.
  Future<void> upsertPreset(EqualizerPreset preset) {
    final bandLevelsJson = jsonEncode(preset.bandGains);
    return _database
        .into(_database.equalizerPresets)
        .insert(
          EqualizerPresetsCompanion.insert(
            id: preset.id,
            name: preset.name,
            bandLevelsJson: bandLevelsJson,
          ),
          onConflict: DoUpdate(
            (_) => EqualizerPresetsCompanion(
              bandLevelsJson: Value(bandLevelsJson),
            ),
          ),
        );
  }

  /// One-off (non-reactive) fetch, used by `BackupRepository`.
  Future<List<EqualizerPreset>> allPresets() async {
    final rows = await _database.select(_database.equalizerPresets).get();
    return rows.map(EqualizerPreset.fromRow).toList(growable: false);
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
