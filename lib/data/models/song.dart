import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../datasources/app_database.dart';

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
    this.moodTagId,
    this.isLiked = false,
    this.isMissing = false,
    this.playCount = 0,
    this.lastPlayedAt,
  });

  factory Song.fromRow(SongRow row) {
    return Song(
      id: row.id,
      filePath: row.filePath,
      title: row.title,
      artist: row.artist,
      album: row.album,
      duration: Duration(milliseconds: row.durationMs),
      moodTagId: row.moodTagId,
      isLiked: row.isLiked,
      isMissing: row.isMissing,
      playCount: row.playCount,
      lastPlayedAt: row.lastPlayedAt,
    );
  }

  final String id;
  final String filePath;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String? moodTagId;
  final bool isLiked;
  final bool isMissing;
  final int playCount;
  final DateTime? lastPlayedAt;

  Song copyWith({
    String? title,
    String? artist,
    String? album,
    String? moodTagId,
    bool? isLiked,
    bool? isMissing,
    int? playCount,
    DateTime? lastPlayedAt,
  }) {
    return Song(
      id: id,
      filePath: filePath,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration,
      moodTagId: moodTagId ?? this.moodTagId,
      isLiked: isLiked ?? this.isLiked,
      isMissing: isMissing ?? this.isMissing,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
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
      moodTagId: Value(moodTagId),
      isLiked: Value(isLiked),
      isMissing: Value(isMissing),
      playCount: Value(playCount),
      lastPlayedAt: Value(lastPlayedAt),
    );
  }

  @override
  bool operator ==(Object other) => other is Song && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
