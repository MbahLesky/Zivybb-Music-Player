import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../data/models/song.dart';
import '../../data/repositories/song_repository.dart';
import 'media_scanner_service.dart';

/// Finds relocated files for songs flagged as missing and re-links them
/// (SRS F-5.4), matching the `MissingFileService` in Entity-Diagrams-UML.md.
class MissingFileService {
  MissingFileService({required this._songRepository, required this._scanner});

  final SongRepository _songRepository;
  final MediaScannerService _scanner;

  /// Searches [deviceSongs] (a fresh device scan) for a candidate
  /// replacement for [song], matching by filename or by title+artist.
  /// Returns the candidate's file path, or `null` if nothing matches.
  String? scanForMatch(Song song, List<Song> deviceSongs) {
    for (final candidate in deviceSongs) {
      if (candidate.filePath == song.filePath) continue;
      final sameFilename =
          p.basename(candidate.filePath) == p.basename(song.filePath);
      final sameMetadata =
          candidate.title == song.title && candidate.artist == song.artist;
      if (sameFilename || sameMetadata) {
        return candidate.filePath;
      }
    }
    return null;
  }

  /// Re-links every missing song it can find a match for.
  Future<void> autoRelinkAll() async {
    final missing = await _songRepository.missingSongs();
    if (missing.isEmpty) return;

    final deviceSongs = await _scanner.scanLibrary();
    for (final song in missing) {
      final match = scanForMatch(song, deviceSongs);
      if (match != null) {
        await _songRepository.relink(song.id, match);
      }
    }
  }
}

final missingFileServiceProvider = Provider<MissingFileService>((ref) {
  return MissingFileService(
    songRepository: ref.watch(songRepositoryProvider),
    scanner: ref.watch(mediaScannerServiceProvider),
  );
});
