import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/vibe_tag.dart';
import '../../../data/repositories/vibe_tag_repository.dart';

final vibeTagsStreamProvider = StreamProvider<List<VibeTag>>((ref) {
  return ref.watch(vibeTagRepositoryProvider).watchVibeTags();
});

/// Every song's vibe ids, keyed by song id — one shared stream so song
/// tiles can render their chips without a query per row.
final songVibeIdsStreamProvider = StreamProvider<Map<String, List<String>>>((
  ref,
) {
  return ref.watch(vibeTagRepositoryProvider).watchSongVibeIds();
});

/// A single song's vibe ids, for the tagging sheet.
final vibeIdsForSongProvider = StreamProvider.family<Set<String>, String>((
  ref,
  songId,
) {
  return ref.watch(vibeTagRepositoryProvider).watchVibeIdsForSong(songId);
});

/// The vibes attached to [songId], resolved to full tags in the vibe list's
/// own order so chips read consistently everywhere.
final vibesForSongProvider = Provider.family<List<VibeTag>, String>((
  ref,
  songId,
) {
  final tags = ref.watch(vibeTagsStreamProvider).value ?? const [];
  final idsBySong = ref.watch(songVibeIdsStreamProvider).value ?? const {};
  final ids = idsBySong[songId];
  if (ids == null || ids.isEmpty) return const [];
  final idSet = ids.toSet();
  return [
    for (final tag in tags)
      if (idSet.contains(tag.id)) tag,
  ];
});
