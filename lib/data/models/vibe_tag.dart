import 'package:flutter/foundation.dart';

import '../datasources/app_database.dart';

/// A folder grouping related vibes — Mood, Place, Time, Genre and so on.
///
/// A vibe belongs to at most one of these (see [VibeTag.categoryId]); vibes
/// with none are shown under [uncategorisedName].
@immutable
class VibeCategory {
  const VibeCategory({
    required this.id,
    required this.name,
    required this.colorHex,
  });

  factory VibeCategory.fromRow(VibeCategoryRow row) {
    return VibeCategory(id: row.id, name: row.name, colorHex: row.colorHex);
  }

  /// Heading the vibes with no folder are listed under. Not a real category —
  /// there is no row for it, and a vibe lands here by having a null
  /// [VibeTag.categoryId].
  static const uncategorisedName = 'Uncategorised';

  final String id;
  final String name;
  final String colorHex;

  @override
  bool operator ==(Object other) => other is VibeCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A vibe (mood/energy) label songs can be tagged with (SRS F-2.6). A song
/// can carry any number of vibes.
@immutable
class VibeTag {
  const VibeTag({
    required this.id,
    required this.label,
    required this.colorHex,
    this.categoryId,
  });

  factory VibeTag.fromRow(VibeTagRow row) {
    return VibeTag(
      id: row.id,
      label: row.label,
      colorHex: row.colorHex,
      categoryId: row.categoryId,
    );
  }

  final String id;
  final String label;
  final String colorHex;

  /// The [VibeCategory] this vibe sits in, or null for uncategorised.
  final String? categoryId;

  @override
  bool operator ==(Object other) => other is VibeTag && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A folder together with the vibes inside it, in display order.
///
/// [category] is null for the uncategorised group, which always sorts last.
@immutable
class VibeGroup {
  const VibeGroup({required this.category, required this.vibes});

  final VibeCategory? category;
  final List<VibeTag> vibes;

  String get name => category?.name ?? VibeCategory.uncategorisedName;
}
