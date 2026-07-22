import 'package:flutter/material.dart';

/// A mood/energy label a song can be tagged with.
///
/// Moods are color-coded rather than icon-coded so the set stays scalable as
/// more moods are added.
@immutable
class MoodTag {
  const MoodTag({
    required this.id,
    required this.label,
    required this.colorValue,
  });

  final String id;
  final String label;

  /// Stored as an int rather than a [Color] so the tag serializes directly
  /// into local storage and backups.
  final int colorValue;

  Color get color => Color(colorValue);

  @override
  bool operator ==(Object other) =>
      other is MoodTag && other.runtimeType == runtimeType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
