import 'package:flutter/foundation.dart';

import '../datasources/app_database.dart';

/// A vibe (mood/energy) label songs can be tagged with (SRS F-2.6). A song
/// can carry any number of vibes.
@immutable
class VibeTag {
  const VibeTag({
    required this.id,
    required this.label,
    required this.colorHex,
  });

  factory VibeTag.fromRow(VibeTagRow row) {
    return VibeTag(id: row.id, label: row.label, colorHex: row.colorHex);
  }

  final String id;
  final String label;
  final String colorHex;

  @override
  bool operator ==(Object other) => other is VibeTag && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
