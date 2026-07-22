import 'package:flutter/foundation.dart';

/// A single track in the user's local library.
///
/// A song is identified by [id] rather than [filePath] so that re-linking a
/// moved file keeps the user's likes, mood tag, and playlist membership.
@immutable
class Song {
  const Song({
    required this.id,
    required this.filePath,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.moodTagId,
    this.isLiked = false,
    this.isMissing = false,
  });

  final String id;
  final String filePath;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String? moodTagId;
  final bool isLiked;

  /// True once a scan has failed to find [filePath]. Missing songs stay in the
  /// library so they can be re-linked instead of silently disappearing.
  final bool isMissing;

  /// The directory holding this song, used to group the folder browser.
  String get folderPath {
    final separator = filePath.lastIndexOf(RegExp(r'[/\\]'));
    return separator == -1 ? '' : filePath.substring(0, separator);
  }

  /// The last path segment of [folderPath], for display.
  String get folderName {
    final path = folderPath;
    if (path.isEmpty) return 'Unknown folder';

    final separator = path.lastIndexOf(RegExp(r'[/\\]'));
    return separator == -1 ? path : path.substring(separator + 1);
  }

  Song copyWith({
    String? filePath,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? moodTagId,
    bool? isLiked,
    bool? isMissing,
  }) {
    return Song(
      id: id,
      filePath: filePath ?? this.filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      moodTagId: moodTagId ?? this.moodTagId,
      isLiked: isLiked ?? this.isLiked,
      isMissing: isMissing ?? this.isMissing,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Song && other.runtimeType == runtimeType && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
