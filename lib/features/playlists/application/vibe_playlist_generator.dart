import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/playlist_repository.dart';
import '../../../data/repositories/vibe_tag_repository.dart';

/// Keeps the auto-generated vibe playlists in sync with each song's vibes
/// (SRS F-4.2). Regenerated wholesale rather than incrementally patched
/// — the library is small enough (personal device) that this is simple and
/// always correct, matching the note in Entity-Diagrams-UML.md that
/// auto-generated playlists are "derived from MOOD_TAG groupings" rather
/// than manually edited. A song carrying several vibes now appears in each
/// of their playlists.
class VibePlaylistGenerator {
  VibePlaylistGenerator({
    required this._vibeTagRepository,
    required this._playlistRepository,
  });

  final VibeTagRepository _vibeTagRepository;
  final PlaylistRepository _playlistRepository;

  Future<void> regenerateAll() async {
    final tags = await _vibeTagRepository.allVibeTags();
    // One pass over the join table, inverted in memory, rather than a query
    // per tag.
    final vibeIdsBySong = await _vibeTagRepository.allSongVibeIds();
    final songIdsByVibe = <String, List<String>>{};
    for (final entry in vibeIdsBySong.entries) {
      for (final vibeId in entry.value) {
        songIdsByVibe.putIfAbsent(vibeId, () => []).add(entry.key);
      }
    }

    for (final tag in tags) {
      await _playlistRepository.replaceAutoPlaylistSongs(
        sourceVibeTagId: tag.id,
        name: '${tag.label} Mix',
        songIds: songIdsByVibe[tag.id] ?? const [],
      );
    }
  }

  /// Deletes a vibe tag along with its auto-generated playlist. The
  /// playlist must go first, before the tag's `onDelete: setNull` foreign
  /// key clears the link between them.
  Future<void> deleteVibeTag(String tagId) async {
    await _playlistRepository.deleteAutoPlaylistForVibeTag(tagId);
    await _vibeTagRepository.deleteVibeTag(tagId);
  }
}

final vibePlaylistGeneratorProvider = Provider<VibePlaylistGenerator>((ref) {
  return VibePlaylistGenerator(
    vibeTagRepository: ref.watch(vibeTagRepositoryProvider),
    playlistRepository: ref.watch(playlistRepositoryProvider),
  );
});
