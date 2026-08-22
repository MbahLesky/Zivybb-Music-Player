import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/song.dart';
import '../../vibe_tagging/application/vibe_tagging_controller.dart';

/// Orders the library list can be shown in.
///
/// The play-count and last-played orders are what the `playCount` /
/// `lastPlayedAt` columns exist for beyond Song Discovery — they turn
/// listening history into something the user can actually browse.
enum LibrarySort {
  title,
  artist,
  album,
  durationShortest,
  durationLongest,
  mostPlayed,
  leastPlayed,
  recentlyPlayed,
  newestAdded;

  String get label => switch (this) {
    LibrarySort.title => 'Title (A–Z)',
    LibrarySort.artist => 'Artist (A–Z)',
    LibrarySort.album => 'Album (A–Z)',
    LibrarySort.durationShortest => 'Shortest first',
    LibrarySort.durationLongest => 'Longest first',
    LibrarySort.mostPlayed => 'Most played',
    LibrarySort.leastPlayed => 'Least played',
    LibrarySort.recentlyPlayed => 'Recently played',
    LibrarySort.newestAdded => 'Newest added',
  };
}

/// Narrows the library to a subset before sorting. Independent of the search
/// query — the two combine.
enum LibraryFilter {
  all,
  liked,
  tagged,
  untagged,
  neverPlayed,
  underOneMinute,
  overFiveMinutes;

  String get label => switch (this) {
    LibraryFilter.all => 'All songs',
    LibraryFilter.liked => 'Liked only',
    LibraryFilter.tagged => 'Has a vibe',
    LibraryFilter.untagged => 'No vibe',
    LibraryFilter.neverPlayed => 'Never played',
    LibraryFilter.underOneMinute => 'Under 1 minute',
    LibraryFilter.overFiveMinutes => 'Over 5 minutes',
  };

  /// Whether [song] belongs in this filter.
  ///
  /// Vibes live in a join table rather than on the song, so the tagged /
  /// untagged cases can't be answered from [song] alone — [vibeTaggedSongIds]
  /// carries the set of songs that have at least one. An empty set therefore
  /// reads as "nothing is tagged", which is exactly right before the vibe
  /// stream has loaded.
  bool matches(
    Song song, {
    Set<String> vibeTaggedSongIds = const {},
  }) => switch (this) {
    LibraryFilter.all => true,
    LibraryFilter.liked => song.isLiked,
    LibraryFilter.tagged => vibeTaggedSongIds.contains(song.id),
    LibraryFilter.untagged => !vibeTaggedSongIds.contains(song.id),
    LibraryFilter.neverPlayed => song.playCount == 0,
    LibraryFilter.underOneMinute => song.duration < const Duration(minutes: 1),
    LibraryFilter.overFiveMinutes => song.duration > const Duration(minutes: 5),
  };
}

/// The user's current search text for the library lists. Empty means no
/// filtering.
final librarySearchQueryProvider = StateProvider<String>((ref) => '');

/// The user's current library sort order.
final librarySortProvider = StateProvider<LibrarySort>(
  (ref) => LibrarySort.title,
);

/// The user's current library filter.
final libraryFilterProvider = StateProvider<LibraryFilter>(
  (ref) => LibraryFilter.all,
);

/// The vibe folder the library is narrowed to, or null for "any folder".
///
/// Deliberately separate from [LibraryFilter]: folders are user-created rows,
/// so they can't be enum cases, and the two narrow along different axes —
/// "liked songs that carry a Mood vibe" is a reasonable thing to ask for.
final libraryVibeCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// The song ids the active vibe-folder filter allows through, or null when no
/// folder is selected — which `applyLibraryView` reads as "don't narrow",
/// distinct from an empty set meaning "nothing in that folder is tagged".
final libraryVibeCategoryRestrictionProvider = Provider<Set<String>?>((ref) {
  final categoryId = ref.watch(libraryVibeCategoryFilterProvider);
  if (categoryId == null) return null;
  return ref.watch(songIdsInVibeCategoryProvider(categoryId));
});

/// The name of the folder the library is narrowed to, or null when it isn't.
/// Used to explain an unexpectedly short list.
final libraryVibeCategoryNameProvider = Provider<String?>((ref) {
  final categoryId = ref.watch(libraryVibeCategoryFilterProvider);
  if (categoryId == null) return null;
  final categories = ref.watch(vibeCategoriesStreamProvider).value ?? const [];
  for (final category in categories) {
    if (category.id == categoryId) return category.name;
  }
  return null;
});

/// Applies the active search query, filter, and sort order to [songs].
///
/// Deliberately a pure function over an already-loaded list rather than a
/// database query: the library is a personal-sized collection held in memory
/// anyway, and this keeps searching instant and keeps every list (All Songs,
/// Liked, folder contents) filtering identically.
/// [restrictToSongIds], when given, narrows the list to those songs before
/// anything else — it carries the vibe-folder filter, which can only be
/// answered from the vibe join tables rather than from a [Song].
List<Song> applyLibraryView(
  List<Song> songs, {
  required String query,
  required LibrarySort sort,
  LibraryFilter filter = LibraryFilter.all,
  Set<String> vibeTaggedSongIds = const {},
  Set<String>? restrictToSongIds,
}) {
  final trimmed = query.trim().toLowerCase();
  final filtered = songs.where((song) {
    if (restrictToSongIds != null && !restrictToSongIds.contains(song.id)) {
      return false;
    }
    if (!filter.matches(song, vibeTaggedSongIds: vibeTaggedSongIds)) {
      return false;
    }
    if (trimmed.isEmpty) return true;
    return song.title.toLowerCase().contains(trimmed) ||
        song.artist.toLowerCase().contains(trimmed) ||
        song.album.toLowerCase().contains(trimmed);
  }).toList();

  int byText(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());

  switch (sort) {
    case LibrarySort.title:
      filtered.sort((a, b) => byText(a.title, b.title));
    case LibrarySort.artist:
      filtered.sort((a, b) {
        final result = byText(a.artist, b.artist);
        return result != 0 ? result : byText(a.title, b.title);
      });
    case LibrarySort.album:
      filtered.sort((a, b) {
        final result = byText(a.album, b.album);
        return result != 0 ? result : byText(a.title, b.title);
      });
    case LibrarySort.durationShortest:
      filtered.sort((a, b) => a.duration.compareTo(b.duration));
    case LibrarySort.durationLongest:
      filtered.sort((a, b) => b.duration.compareTo(a.duration));
    case LibrarySort.mostPlayed:
      filtered.sort((a, b) {
        final result = b.playCount.compareTo(a.playCount);
        return result != 0 ? result : byText(a.title, b.title);
      });
    case LibrarySort.leastPlayed:
      filtered.sort((a, b) {
        final result = a.playCount.compareTo(b.playCount);
        return result != 0 ? result : byText(a.title, b.title);
      });
    case LibrarySort.recentlyPlayed:
      filtered.sort((a, b) {
        // Never-played songs sort last rather than being treated as
        // infinitely old, so the list reads as a genuine history.
        final aPlayed = a.lastPlayedAt;
        final bPlayed = b.lastPlayedAt;
        if (aPlayed == null && bPlayed == null) return byText(a.title, b.title);
        if (aPlayed == null) return 1;
        if (bPlayed == null) return -1;
        return bPlayed.compareTo(aPlayed);
      });
    case LibrarySort.newestAdded:
      filtered.sort((a, b) {
        // Songs whose date-added the media store never gave us sort last for
        // the same reason never-played ones do above — an unknown date is
        // not evidence of an old one, and a library cached before the column
        // existed would otherwise show as entirely "oldest" until its next
        // device scan.
        final aAdded = a.dateAdded;
        final bAdded = b.dateAdded;
        if (aAdded == null && bAdded == null) return byText(a.title, b.title);
        if (aAdded == null) return 1;
        if (bAdded == null) return -1;
        final result = bAdded.compareTo(aAdded);
        return result != 0 ? result : byText(a.title, b.title);
      });
  }
  return filtered;
}
