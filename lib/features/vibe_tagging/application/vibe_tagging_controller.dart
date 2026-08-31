import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/vibe_tag.dart';
import '../../../data/repositories/vibe_tag_repository.dart';

final vibeTagsStreamProvider = StreamProvider<List<VibeTag>>((ref) {
  return ref.watch(vibeTagRepositoryProvider).watchVibeTags();
});

/// The folders vibes are grouped into, in the user's order.
final vibeCategoriesStreamProvider = StreamProvider<List<VibeCategory>>((ref) {
  return ref.watch(vibeTagRepositoryProvider).watchVibeCategories();
});

/// Every vibe arranged under its folder, folders in their own order and
/// vibes in theirs, with the uncategorised ones last.
///
/// Derived here rather than by ordering the query, so nothing depends on the
/// two `sortOrder` columns happening to agree with each other. Empty folders
/// are kept: a folder with nothing in it yet still needs somewhere to drop
/// a vibe.
final vibeGroupsProvider = Provider<List<VibeGroup>>((ref) {
  final categories = ref.watch(vibeCategoriesStreamProvider).value ?? const [];
  final tags = ref.watch(vibeTagsStreamProvider).value ?? const [];

  final known = {for (final category in categories) category.id};
  final groups = [
    for (final category in categories)
      VibeGroup(
        category: category,
        vibes: [
          for (final tag in tags)
            if (tag.categoryId == category.id) tag,
        ],
      ),
  ];

  // A vibe whose folder has gone missing lands with the uncategorised ones
  // rather than disappearing — older installs never had the foreign key that
  // would have cleared the id.
  final loose = [
    for (final tag in tags)
      if (tag.categoryId == null || !known.contains(tag.categoryId)) tag,
  ];
  if (loose.isNotEmpty) {
    groups.add(VibeGroup(category: null, vibes: loose));
  }
  return groups;
});

/// The ids of songs carrying at least one vibe from [categoryId], for the
/// library's folder filter.
final songIdsInVibeCategoryProvider = Provider.family<Set<String>, String>((
  ref,
  categoryId,
) {
  final tags = ref.watch(vibeTagsStreamProvider).value ?? const [];
  final idsInCategory = {
    for (final tag in tags)
      if (tag.categoryId == categoryId) tag.id,
  };
  if (idsInCategory.isEmpty) return const {};

  final idsBySong = ref.watch(songVibeIdsStreamProvider).value ?? const {};
  return {
    for (final entry in idsBySong.entries)
      if (entry.value.any(idsInCategory.contains)) entry.key,
  };
});

/// Every song's vibe ids, keyed by song id — one shared stream so song
/// tiles can render their chips without a query per row.
final songVibeIdsStreamProvider = StreamProvider<Map<String, List<String>>>((
  ref,
) {
  return ref.watch(vibeTagRepositoryProvider).watchSongVibeIds();
});

/// The ids of songs carrying at least one vibe, for the library's
/// tagged/untagged filter. Empty until the vibe stream loads, which reads as
/// "nothing tagged yet" rather than as an error.
final vibeTaggedSongIdsProvider = Provider<Set<String>>((ref) {
  final idsBySong = ref.watch(songVibeIdsStreamProvider).value ?? const {};
  return {
    for (final entry in idsBySong.entries)
      if (entry.value.isNotEmpty) entry.key,
  };
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
