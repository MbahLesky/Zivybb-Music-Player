import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/song.dart';

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
  recentlyPlayed;

  String get label => switch (this) {
    LibrarySort.title => 'Title (A–Z)',
    LibrarySort.artist => 'Artist (A–Z)',
    LibrarySort.album => 'Album (A–Z)',
    LibrarySort.durationShortest => 'Shortest first',
    LibrarySort.durationLongest => 'Longest first',
    LibrarySort.mostPlayed => 'Most played',
    LibrarySort.leastPlayed => 'Least played',
    LibrarySort.recentlyPlayed => 'Recently played',
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

/// Applies the active search query, filter, and sort order to [songs].
///
/// Deliberately a pure function over an already-loaded list rather than a
/// database query: the library is a personal-sized collection held in memory
/// anyway, and this keeps searching instant and keeps every list (All Songs,
/// Liked, folder contents) filtering identically.
List<Song> applyLibraryView(
  List<Song> songs, {
  required String query,
  required LibrarySort sort,
  LibraryFilter filter = LibraryFilter.all,
  Set<String> vibeTaggedSongIds = const {},
}) {
  final trimmed = query.trim().toLowerCase();
  final filtered = songs.where((song) {
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
  }
  return filtered;
}
