import 'package:on_audio_query_pluse/on_audio_query.dart';

import '../../data/models/song.dart';

/// Thrown when the user has not granted permission to read the device's
/// local media library.
class MediaPermissionDeniedException implements Exception {
  const MediaPermissionDeniedException();
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

  /// Requests (if needed) and reports whether local-library access is
  /// granted.
  Future<bool> hasLibraryAccess() => _audioQuery.checkAndRequest();

  /// Scans the device for local audio tracks.
  ///
  /// Throws [MediaPermissionDeniedException] if the user has not granted
  /// media access.
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
