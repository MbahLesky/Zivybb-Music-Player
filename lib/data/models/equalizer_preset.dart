import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../datasources/app_database.dart';

/// A named set of equalizer band gains the user can select (SRS F-1.6).
@immutable
class EqualizerPreset {
  const EqualizerPreset({
    required this.id,
    required this.name,
    required this.bandGains,
  });

  factory EqualizerPreset.fromRow(EqualizerPresetRow row) {
    final decoded = (jsonDecode(row.bandLevelsJson) as List)
        .cast<num>()
        .map((gain) => gain.toDouble())
        .toList(growable: false);
    return EqualizerPreset(id: row.id, name: row.name, bandGains: decoded);
  }

  final String id;
  final String name;

  /// Gains in decibels across a fixed reference set of bands (bass to
  /// treble); mapped onto the device's actual bands at apply-time since
  /// those are only known at runtime.
  final List<double> bandGains;

  @override
  bool operator ==(Object other) => other is EqualizerPreset && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
