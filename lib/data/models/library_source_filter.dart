import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Decides which of the device's audio files belong in the library.
///
/// A media store holds far more than music: WhatsApp voice notes, call
/// recordings, ringtones, notification blips. Scanning them all in made every
/// one of them a "song" that shuffle could land on, which is what this filter
/// exists to stop.
///
/// Three layers, cheapest first:
///  1. [autoExcludeNonMusicFolders] — folders whose name gives them away
///     ([nonMusicFolderPatterns]) are out unless the user says otherwise.
///  2. [minimumDuration] — a clip shorter than this is a message, not a track.
///  3. [includedFolders] / [excludedFolders] — the user's own per-folder
///     calls, which beat both of the above.
///
/// Deliberately pure and path-based: the same instance decides both what a
/// fresh scan keeps and which already-cached rows have to go, so switching a
/// folder off clears out what an earlier scan let in.
@immutable
class LibrarySourceFilter {
  const LibrarySourceFilter({
    this.autoExcludeNonMusicFolders = true,
    this.minimumDuration = defaultMinimumDuration,
    this.includedFolders = const <String>{},
    this.excludedFolders = const <String>{},
  });

  /// Short enough to keep interludes and skits, long enough to drop the
  /// average voice note.
  static const defaultMinimumDuration = Duration(seconds: 30);

  /// The lengths offered in Settings. Zero means "keep everything".
  static const minimumDurationChoices = <Duration>[
    Duration.zero,
    Duration(seconds: 15),
    Duration(seconds: 30),
    Duration(seconds: 45),
    Duration(seconds: 60),
    Duration(seconds: 90),
  ];

  /// Lowercase fragments that mark a folder as holding something other than
  /// music. Matched against each segment of the folder path, so
  /// `.../WhatsApp Voice Notes/2026` is caught by its parent.
  ///
  /// Only ever a *default*: a folder the user has explicitly switched on
  /// stays on however it is named.
  static const nonMusicFolderPatterns = <String>[
    'whatsapp',
    'telegram',
    'signal',
    'viber',
    'messenger',
    'wechat',
    'voice note',
    'voicenote',
    'voice record',
    'recording',
    'recorder',
    'ringtone',
    'notification',
    'alarm',
    'ui sound',
    'screen record',
    'screenrecord',
    'audiobook',
    'podcast',
  ];

  /// Skip the name-based guess and take every folder the user hasn't
  /// explicitly excluded.
  final bool autoExcludeNonMusicFolders;

  /// Tracks shorter than this are dropped. [Duration.zero] keeps them all.
  final Duration minimumDuration;

  /// Folders the user switched back on, overriding
  /// [autoExcludeNonMusicFolders].
  final Set<String> includedFolders;

  /// Folders the user switched off by hand.
  final Set<String> excludedFolders;

  /// Whether a file at [filePath] of [duration] belongs in the library.
  ///
  /// A zero duration passes the length test: the media store leaves the
  /// column empty on some devices, and dropping every track it failed to
  /// measure would be worse than letting a short one through.
  bool allows(String filePath, Duration duration) {
    if (duration > Duration.zero && duration < minimumDuration) return false;
    return allowsFolder(p.dirname(filePath));
  }

  /// Whether [folder] is scanned at all. The user's explicit choice wins; the
  /// name-based guess only decides folders they haven't ruled on.
  bool allowsFolder(String folder) {
    if (_contains(includedFolders, folder)) return true;
    if (_contains(excludedFolders, folder)) return false;
    if (!autoExcludeNonMusicFolders) return true;
    return !looksLikeNonMusic(folder);
  }

  /// Whether [folder]'s state is the user's doing rather than the name-based
  /// default — what Settings uses to mark the row as decided.
  bool isUserChoice(String folder) =>
      _contains(includedFolders, folder) || _contains(excludedFolders, folder);

  /// Whether any segment of [folder] names it as somewhere music doesn't live.
  static bool looksLikeNonMusic(String folder) {
    for (final segment in p.split(folder)) {
      final name = segment.toLowerCase();
      for (final pattern in nonMusicFolderPatterns) {
        if (name.contains(pattern)) return true;
      }
    }
    return false;
  }

  /// The filter with [folder] switched on or off.
  ///
  /// Clears whichever override set it used to sit in, so a folder is never in
  /// both, and records the choice only when it differs from what the
  /// name-based default would have done — the stored overrides stay a list of
  /// genuine decisions rather than a copy of every folder on the device.
  LibrarySourceFilter withFolder(String folder, {required bool included}) {
    final nextIncluded = _without(includedFolders, folder);
    final nextExcluded = _without(excludedFolders, folder);
    final defaultAllows =
        !autoExcludeNonMusicFolders || !looksLikeNonMusic(folder);
    if (included != defaultAllows) {
      (included ? nextIncluded : nextExcluded).add(folder);
    }
    return copyWith(
      includedFolders: nextIncluded,
      excludedFolders: nextExcluded,
    );
  }

  LibrarySourceFilter copyWith({
    bool? autoExcludeNonMusicFolders,
    Duration? minimumDuration,
    Set<String>? includedFolders,
    Set<String>? excludedFolders,
  }) {
    return LibrarySourceFilter(
      autoExcludeNonMusicFolders:
          autoExcludeNonMusicFolders ?? this.autoExcludeNonMusicFolders,
      minimumDuration: minimumDuration ?? this.minimumDuration,
      includedFolders: includedFolders ?? this.includedFolders,
      excludedFolders: excludedFolders ?? this.excludedFolders,
    );
  }

  /// The two override sets as one JSON object, which is how they are stored
  /// (a single settings column) and backed up.
  String overridesToJson() => jsonEncode({
    'included': includedFolders.toList()..sort(),
    'excluded': excludedFolders.toList()..sort(),
  });

  /// Reads [overridesToJson] back. Anything unparseable is treated as "no
  /// overrides" rather than throwing — a corrupt settings value should cost
  /// the user their folder choices, not the whole library screen.
  static ({Set<String> included, Set<String> excluded}) overridesFromJson(
    String? json,
  ) {
    const empty = (included: <String>{}, excluded: <String>{});
    if (json == null || json.isEmpty) return empty;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map) return empty;
      return (
        included: _stringSet(decoded['included']),
        excluded: _stringSet(decoded['excluded']),
      );
    } on FormatException {
      return empty;
    }
  }

  static Set<String> _stringSet(Object? raw) {
    if (raw is! List) return <String>{};
    return raw.whereType<String>().toSet();
  }

  static bool _contains(Set<String> folders, String folder) {
    final target = _normalize(folder);
    return folders.any((other) => _normalize(other) == target);
  }

  static Set<String> _without(Set<String> folders, String folder) {
    final target = _normalize(folder);
    return folders.where((other) => _normalize(other) != target).toSet();
  }

  /// Paths are compared normalized and case-insensitively: Android's media
  /// store is inconsistent about trailing separators and case, and a folder
  /// the user switched off should stay off when the next scan spells it
  /// slightly differently.
  static String _normalize(String folder) => p.normalize(folder).toLowerCase();

  @override
  bool operator ==(Object other) =>
      other is LibrarySourceFilter &&
      other.autoExcludeNonMusicFolders == autoExcludeNonMusicFolders &&
      other.minimumDuration == minimumDuration &&
      setEquals(other.includedFolders, includedFolders) &&
      setEquals(other.excludedFolders, excludedFolders);

  @override
  int get hashCode => Object.hash(
    autoExcludeNonMusicFolders,
    minimumDuration,
    Object.hashAllUnordered(includedFolders),
    Object.hashAllUnordered(excludedFolders),
  );
}
