import 'package:flutter/foundation.dart';

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
  });

  final String id;
  final String filePath;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String? moodTagId;
  final bool isLiked;
  final bool isMissing;

  Song copyWith({
    String? title,
    String? artist,
    String? album,
    String? moodTagId,
    bool? isLiked,
    bool? isMissing,
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
    );
  }

  @override
  bool operator ==(Object other) => other is Song && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
