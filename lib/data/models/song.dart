import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../datasources/app_database.dart';

/// Prefix distinguishing a video's library id from an audio track's.
///
/// MediaStore numbers its audio and video collections independently, so the
/// same numeric id can name both a song and a video; without this prefix the
/// two would collide in the `songs` table.
const videoSongIdPrefix = 'video:';

/// A single local audio track in the user's library.
@immutable
class Song {
  const Song({
    required this.id,
    required this.filePath,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    this.isVideo = false,
    this.isLiked = false,
    this.isMissing = false,
    this.playCount = 0,
    this.lastPlayedAt,
    this.dateAdded,
  });

  factory Song.fromRow(SongRow row) {
    return Song(
      id: row.id,
      filePath: row.filePath,
      title: row.title,
      artist: row.artist,
      album: row.album,
      duration: Duration(milliseconds: row.durationMs),
      isVideo: row.isVideo,
      isLiked: row.isLiked,
      isMissing: row.isMissing,
      playCount: row.playCount,
      lastPlayedAt: row.lastPlayedAt,
      dateAdded: row.dateAdded,
    );
  }

  final String id;
  final String filePath;
  final String title;
  final String artist;
  final String album;
  final Duration duration;

  /// A video file played as audio. Its [id] is namespaced with
  /// [videoSongIdPrefix], and it has no queryable album artwork.
  final bool isVideo;
  final bool isLiked;
  final bool isMissing;
  final int playCount;
  final DateTime? lastPlayedAt;

  /// When the device first saw this file. Null means "unknown" — either the
  /// row predates the column or the media store had no value — and every
  /// reader sorts those last rather than treating them as ancient.
  final DateTime? dateAdded;

  Song copyWith({
    String? title,
    String? artist,
    String? album,
    bool? isLiked,
    bool? isMissing,
    int? playCount,
    DateTime? lastPlayedAt,
    DateTime? dateAdded,
  }) {
    return Song(
      id: id,
      filePath: filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration,
      isVideo: isVideo,
      isLiked: isLiked ?? this.isLiked,
      isMissing: isMissing ?? this.isMissing,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  SongsCompanion toCompanion() {
    return SongsCompanion.insert(
      id: id,
      filePath: filePath,
      title: title,
      artist: artist,
      album: album,
      durationMs: duration.inMilliseconds,
      isVideo: Value(isVideo),
      isLiked: Value(isLiked),
      isMissing: Value(isMissing),
      playCount: Value(playCount),
      lastPlayedAt: Value(lastPlayedAt),
      dateAdded: Value(dateAdded),
    );
  }

  @override
  bool operator ==(Object other) => other is Song && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
