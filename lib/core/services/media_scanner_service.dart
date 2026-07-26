import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';

import '../../data/models/song.dart';

/// Thrown when the device's media library can't be read because the user
/// hasn't granted the required media permissions.
class MediaPermissionDeniedException implements Exception {
  const MediaPermissionDeniedException();

  @override
  String toString() =>
      'Zivybb needs permission to read the media on your device.';
}

/// Scans the device's local audio library.
///
/// Wraps the platform media-store query plugin so the rest of the app only
/// ever deals in [Song]. Only Android is supported for Version 1 (SRS 2.3);
/// other platforms return an empty library rather than crashing.
class MediaScannerService {
  MediaScannerService({OnAudioQuery? audioQuery})
    : _audioQuery = audioQuery ?? OnAudioQuery();

  final OnAudioQuery _audioQuery;

  /// Requests (if needed) and reports whether media-library access is granted.
  ///
  /// The bundled query plugin needs BOTH `READ_MEDIA_AUDIO` and
  /// `READ_MEDIA_IMAGES` on Android 13+ (it reads album artwork). Critically,
  /// it *crashes* any query call unless both are granted — it replies twice on
  /// its shared method-channel result ("Reply already submitted"). So this
  /// gate must return true before [scanLibrary] is allowed to query.
  Future<bool> hasLibraryAccess() => _audioQuery.checkAndRequest();

  /// Scans the device for local audio tracks.
  ///
  /// Throws [MediaPermissionDeniedException] if access hasn't been granted, so
  /// the query — which would otherwise crash the app without both media
  /// permissions — is never reached until it's safe.
  Future<List<Song>> scanLibrary() async {
    if (!await hasLibraryAccess()) {
      throw const MediaPermissionDeniedException();
    }

    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      ignoreCase: true,
    );

    return songs
        .where((song) => song.isMusic ?? true)
        .map(_toSong)
        .toList(growable: false);
  }

  Song _toSong(SongModel model) {
    return Song(
      id: model.id.toString(),
      filePath: model.data,
      title: model.title,
      artist: model.artist ?? 'Unknown artist',
      album: model.album ?? 'Unknown album',
      duration: Duration(milliseconds: model.duration ?? 0),
    );
  }
}

final mediaScannerServiceProvider = Provider<MediaScannerService>(
  (ref) => MediaScannerService(),
);
