import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/models/song.dart';

/// Reads the device's video files so they can be played as music
/// (Screens.md #11: "Include video files").
///
/// The bundled media-query plugin only covers `MediaStore.Audio`, so this
/// talks to a small `MediaStore.Video` query on the Android side rather than
/// pulling in a second media plugin. Non-Android platforms have no handler
/// registered and simply yield no videos.
class VideoQueryService {
  VideoQueryService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'com.lespa.zivybb/video_query';

  final MethodChannel _channel;

  /// Requests (if needed) and reports whether video access is granted.
  ///
  /// Kept separate from the audio permission gate so the app never asks for
  /// video access unless the user turns the setting on.
  Future<bool> hasVideoAccess() async {
    // Below Android 13 videos fall under the same storage permission the
    // audio scan already holds, so there's nothing extra to request.
    try {
      final status = await Permission.videos.request();
      return status.isGranted || status.isLimited;
    } on MissingPluginException {
      // No permission plugin on this platform (or in tests) — treat video
      // access as unavailable rather than failing the whole library scan.
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Returns the device's video files as [Song]s. Yields an empty list if
  /// permission is refused or the platform has no handler, so a failure here
  /// degrades the library to audio-only rather than breaking the scan.
  Future<List<Song>> queryVideos() async {
    if (!await hasVideoAccess()) return const [];

    final List<Object?>? rows;
    try {
      rows = await _channel.invokeMethod<List<Object?>>('queryVideos');
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    }
    if (rows == null) return const [];

    return [for (final row in rows.cast<Map<Object?, Object?>>()) _toSong(row)];
  }

  Song _toSong(Map<Object?, Object?> row) {
    final title = row['title'] as String? ?? 'Unknown';
    return Song(
      id: '$videoSongIdPrefix${row['id']}',
      filePath: row['filePath'] as String? ?? '',
      title: title,
      artist: row['artist'] as String? ?? 'Unknown artist',
      // MediaStore has no album for videos; its containing folder is the
      // closest useful grouping, matching how the Folders tab reads.
      album: row['album'] as String? ?? 'Videos',
      duration: Duration(
        milliseconds: (row['durationMs'] as num? ?? 0).toInt(),
      ),
      isVideo: true,
    );
  }
}

final videoQueryServiceProvider = Provider<VideoQueryService>(
  (ref) => VideoQueryService(),
);
