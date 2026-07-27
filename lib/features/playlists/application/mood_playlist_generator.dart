import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/mood_tag_repository.dart';
import '../../../data/repositories/playlist_repository.dart';
import '../../../data/repositories/song_repository.dart';

/// Keeps the auto-generated mood playlists in sync with each song's mood
/// tag (SRS F-4.2). Regenerated wholesale rather than incrementally patched
/// — the library is small enough (personal device) that this is simple and
/// always correct, matching the note in Entity-Diagrams-UML.md that
/// auto-generated playlists are "derived from MOOD_TAG groupings" rather
/// than manually edited.
class MoodPlaylistGenerator {
  MoodPlaylistGenerator({
    required this._moodTagRepository,
    required this._songRepository,
    required this._playlistRepository,
  });

  final MoodTagRepository _moodTagRepository;
  final SongRepository _songRepository;
  final PlaylistRepository _playlistRepository;

  Future<void> regenerateAll() async {
    final tags = await _moodTagRepository.allMoodTags();
    for (final tag in tags) {
      final songs = await _songRepository.songsWithMoodTag(tag.id);
      await _playlistRepository.replaceAutoPlaylistSongs(
        sourceMoodTagId: tag.id,
        name: '${tag.label} Mix',
        songIds: songs.map((song) => song.id).toList(),
      );
    }
  }

  /// Deletes a mood tag along with its auto-generated playlist. The
  /// playlist must go first, before the tag's `onDelete: setNull` foreign
  /// key clears the link between them.
  Future<void> deleteMoodTag(String tagId) async {
    await _playlistRepository.deleteAutoPlaylistForMoodTag(tagId);
    await _moodTagRepository.deleteMoodTag(tagId);
  }
}

final moodPlaylistGeneratorProvider = Provider<MoodPlaylistGenerator>((ref) {
  return MoodPlaylistGenerator(
    moodTagRepository: ref.watch(moodTagRepositoryProvider),
    songRepository: ref.watch(songRepositoryProvider),
    playlistRepository: ref.watch(playlistRepositoryProvider),
  );
});
