import '../../data/models/mood_tag.dart';

/// The preset moods every library starts with.
///
/// User-defined moods are stored alongside these once the Mood Tagging screen
/// lands; nothing here assumes the list is closed.
abstract final class MoodTags {
  static const energetic = MoodTag(
    id: 'energetic',
    label: 'Energetic',
    colorValue: 0xFFFF6E6E,
  );
  static const chill = MoodTag(
    id: 'chill',
    label: 'Chill',
    colorValue: 0xFF4CD97B,
  );
  static const focus = MoodTag(
    id: 'focus',
    label: 'Focus',
    colorValue: 0xFF7C4DFF,
  );
  static const sad = MoodTag(id: 'sad', label: 'Sad', colorValue: 0xFF5B8DEF);

  static const presets = <MoodTag>[energetic, chill, focus, sad];

  /// Returns the preset matching [id], or null when the id is unknown or the
  /// song is untagged.
  static MoodTag? byId(String? id) {
    if (id == null) return null;
    for (final tag in presets) {
      if (tag.id == id) return tag;
    }
    return null;
  }
}
