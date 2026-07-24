import 'package:flutter/foundation.dart';

import '../datasources/app_database.dart';

/// A preset mood/energy label a song can be tagged with (SRS F-2.6).
@immutable
class MoodTag {
  const MoodTag({
    required this.id,
    required this.label,
    required this.colorHex,
  });

  factory MoodTag.fromRow(MoodTagRow row) {
    return MoodTag(id: row.id, label: row.label, colorHex: row.colorHex);
  }

  final String id;
  final String label;
  final String colorHex;

  @override
  bool operator ==(Object other) => other is MoodTag && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
