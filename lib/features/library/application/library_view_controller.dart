import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../data/models/song.dart';
import '../../vibe_tagging/application/vibe_tagging_controller.dart';

/// What a list can be ordered by.
///
/// One field plus a [SortDirection], rather than a flat list of orders like
/// "Most played" and "Least played" as separate entries: the same seven
/// fields then read the same way on every screen, and every one of them can
/// be reversed. [directionLabel] is what keeps the wording natural — "Most
/// played first" rather than "Play count, descending".
enum LibrarySortField {
  dateAdded,
  title,
  length,
  artist,
  album,
  playCount,
  lastPlayed;

  String get label => switch (this) {
    LibrarySortField.dateAdded => 'Date added',
    LibrarySortField.title => 'Title',
    LibrarySortField.length => 'Length',
    LibrarySortField.artist => 'Artist',
    LibrarySortField.album => 'Album',
    LibrarySortField.playCount => 'Times played',
    LibrarySortField.lastPlayed => 'Last played',
  };

  /// What each direction actually means for this field, in the user's words.
  String directionLabel(SortDirection direction) {
    final ascending = direction == SortDirection.ascending;
    return switch (this) {
      LibrarySortField.dateAdded => ascending ? 'Oldest first' : 'Newest first',
      LibrarySortField.title ||
      LibrarySortField.artist ||
      LibrarySortField.album => ascending ? 'A–Z' : 'Z–A',
      LibrarySortField.length => ascending ? 'Shortest first' : 'Longest first',
      LibrarySortField.playCount =>
        ascending ? 'Least played first' : 'Most played first',
      LibrarySortField.lastPlayed =>
        ascending ? 'Longest ago first' : 'Recently played first',
    };
  }

  /// The direction that reads as the natural default for this field: names
  /// go A–Z, but "date added" and "last played" are asked for newest-first.
  SortDirection get naturalDirection => switch (this) {
    LibrarySortField.dateAdded ||
    LibrarySortField.playCount ||
    LibrarySortField.lastPlayed => SortDirection.descending,
    _ => SortDirection.ascending,
  };
}

enum SortDirection {
  ascending,
  descending;

  SortDirection get reversed => this == ascending ? descending : ascending;
}

/// One narrowing condition. Several can be on at once and are ANDed together
/// — "liked songs I have never played" is a reasonable thing to ask for.
enum LibraryFilterOption {
  liked,
  hasVibe,
  noVibe,
  neverPlayed;

  String get label => switch (this) {
    LibraryFilterOption.liked => 'Liked only',
    LibraryFilterOption.hasVibe => 'Has a vibe',
    LibraryFilterOption.noVibe => 'No vibe',
    LibraryFilterOption.neverPlayed => 'Never played',
  };

  /// The option this one cannot be on with. A song either carries a vibe or
  /// it doesn't, so having both on would match nothing at all — switching one
  /// on switches the other off instead of showing an empty list.
  LibraryFilterOption? get opposite => switch (this) {
    LibraryFilterOption.hasVibe => LibraryFilterOption.noVibe,
    LibraryFilterOption.noVibe => LibraryFilterOption.hasVibe,
    _ => null,
  };

  /// Whether [song] passes this condition.
  ///
  /// Vibes live in a join table rather than on the song, so the vibe cases
  /// can't be answered from [song] alone — [vibeTaggedSongIds] carries the set
  /// of songs that have at least one. An empty set therefore reads as
  /// "nothing is tagged", which is exactly right before the vibe stream has
  /// loaded.
  bool matches(Song song, {Set<String> vibeTaggedSongIds = const {}}) {
    return switch (this) {
      LibraryFilterOption.liked => song.isLiked,
      LibraryFilterOption.hasVibe => vibeTaggedSongIds.contains(song.id),
      LibraryFilterOption.noVibe => !vibeTaggedSongIds.contains(song.id),
      LibraryFilterOption.neverPlayed => song.playCount == 0,
    };
  }
}

/// How a song list is currently being narrowed and ordered.
///
/// One object shared by every list in the app — All Songs, Liked, a folder, a
/// playlist — so the controls look and behave the same wherever they appear,
/// which is the whole point of it being a value rather than a handful of
/// separate providers.
@immutable
class LibraryView {
  const LibraryView({
    this.filters = const <LibraryFilterOption>{},
    this.vibeCategoryId,
    this.deviceFolder,
    this.sortField = LibrarySortField.title,
    this.direction = SortDirection.ascending,
    this.sortChosen = false,
  });

  final Set<LibraryFilterOption> filters;

  /// The vibe folder the list is narrowed to, or null for any.
  ///
  /// Separate from [filters] because folders are user-created rows, so they
  /// can't be enum cases, and the two narrow along different axes.
  final String? vibeCategoryId;

  /// The device folder the list is narrowed to, or null for any.
  final String? deviceFolder;

  final LibrarySortField sortField;
  final SortDirection direction;

  /// Whether the user has actually picked an order, as opposed to the view
  /// simply carrying a default.
  ///
  /// Lists with a meaningful order of their own — a playlist's stored
  /// sequence above all — keep it until this is true, so opening a playlist
  /// doesn't silently alphabetise it. Once the user chooses a sort, they get
  /// it everywhere.
  final bool sortChosen;

  /// Whether anything is narrowing the list. Drives the badge on the toolbar
  /// button, so a list that is quietly hiding songs always says so.
  int get activeFilterCount =>
      filters.length +
      (vibeCategoryId == null ? 0 : 1) +
      (deviceFolder == null ? 0 : 1);

  bool get isDefault => activeFilterCount == 0 && !sortChosen;

  /// Turns [option] on or off, clearing whatever it contradicts.
  LibraryView toggling(LibraryFilterOption option) {
    final next = Set<LibraryFilterOption>.of(filters);
    if (!next.remove(option)) {
      next.add(option);
      final opposite = option.opposite;
      if (opposite != null) next.remove(opposite);
    }
    return copyWith(filters: next);
  }

  /// Switches to [field], taking that field's natural direction — picking
  /// "Last played" should show recent plays first, not the oldest.
  LibraryView sortedBy(LibrarySortField field) {
    if (field == sortField && sortChosen) return this;
    return copyWith(
      sortField: field,
      direction: field.naturalDirection,
      sortChosen: true,
    );
  }

  LibraryView get reversed =>
      copyWith(direction: direction.reversed, sortChosen: true);

  LibraryView copyWith({
    Set<LibraryFilterOption>? filters,
    Object? vibeCategoryId = _unset,
    Object? deviceFolder = _unset,
    LibrarySortField? sortField,
    SortDirection? direction,
    bool? sortChosen,
  }) {
    return LibraryView(
      filters: filters ?? this.filters,
      vibeCategoryId: identical(vibeCategoryId, _unset)
          ? this.vibeCategoryId
          : vibeCategoryId as String?,
      deviceFolder: identical(deviceFolder, _unset)
          ? this.deviceFolder
          : deviceFolder as String?,
      sortField: sortField ?? this.sortField,
      direction: direction ?? this.direction,
      sortChosen: sortChosen ?? this.sortChosen,
    );
  }

  /// A one-line summary of what is in force, for the toolbar and for
  /// explaining an unexpectedly short list.
  String describe() {
    final parts = <String>[
      for (final filter in LibraryFilterOption.values)
        if (filters.contains(filter)) filter.label,
      if (deviceFolder != null) 'in ${p.basename(deviceFolder!)}',
    ];
    final order = '${sortField.label} · ${sortField.directionLabel(direction)}';
    return parts.isEmpty ? order : '${parts.join(' · ')} · $order';
  }

  @override
  bool operator ==(Object other) =>
      other is LibraryView &&
      setEquals(other.filters, filters) &&
      other.vibeCategoryId == vibeCategoryId &&
      other.deviceFolder == deviceFolder &&
      other.sortField == sortField &&
      other.direction == direction &&
      other.sortChosen == sortChosen;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(filters),
    vibeCategoryId,
    deviceFolder,
    sortField,
    direction,
    sortChosen,
  );

  static const _unset = Object();
}

/// The user's current search text for the library lists. Empty means no
/// filtering.
final librarySearchQueryProvider = StateProvider<String>((ref) => '');

/// The narrowing and ordering every song list shares.
final libraryViewProvider = StateProvider<LibraryView>(
  (ref) => const LibraryView(),
);

/// The song ids the active vibe-folder filter allows through, or null when no
/// folder is selected — which [applyLibraryView] reads as "don't narrow",
/// distinct from an empty set meaning "nothing in that folder is tagged".
final libraryVibeCategoryRestrictionProvider = Provider<Set<String>?>((ref) {
  final categoryId = ref.watch(
    libraryViewProvider.select((view) => view.vibeCategoryId),
  );
  if (categoryId == null) return null;
  return ref.watch(songIdsInVibeCategoryProvider(categoryId));
});

/// The name of the vibe folder the library is narrowed to, or null when it
/// isn't. Used to explain an unexpectedly short list.
final libraryVibeCategoryNameProvider = Provider<String?>((ref) {
  final categoryId = ref.watch(
    libraryViewProvider.select((view) => view.vibeCategoryId),
  );
  if (categoryId == null) return null;
  final categories = ref.watch(vibeCategoriesStreamProvider).value ?? const [];
  for (final category in categories) {
    if (category.id == categoryId) return category.name;
  }
  return null;
});

/// Applies the active search query, filters, and order to [songs].
///
/// Deliberately a pure function over an already-loaded list rather than a
/// database query: the library is a personal-sized collection held in memory
/// anyway, and this keeps searching instant and keeps every list (All Songs,
/// Liked, folder contents, a playlist) filtering identically.
///
/// [restrictToSongIds], when given, narrows the list to those songs before
/// anything else — it carries the vibe-folder filter, which can only be
/// answered from the vibe join tables rather than from a [Song].
/// [preserveOrder] keeps [songs] in the order they arrived instead of sorting
/// them — for a list that has an order of its own worth keeping, such as a
/// playlist the user arranged by hand.
List<Song> applyLibraryView(
  List<Song> songs, {
  required String query,
  required LibraryView view,
  Set<String> vibeTaggedSongIds = const {},
  Set<String>? restrictToSongIds,
  bool preserveOrder = false,
}) {
  final trimmed = query.trim().toLowerCase();
  final folder = view.deviceFolder;

  final filtered = songs.where((song) {
    if (restrictToSongIds != null && !restrictToSongIds.contains(song.id)) {
      return false;
    }
    if (folder != null && p.dirname(song.filePath) != folder) return false;
    for (final filter in view.filters) {
      if (!filter.matches(song, vibeTaggedSongIds: vibeTaggedSongIds)) {
        return false;
      }
    }
    if (trimmed.isEmpty) return true;
    return song.title.toLowerCase().contains(trimmed) ||
        song.artist.toLowerCase().contains(trimmed) ||
        song.album.toLowerCase().contains(trimmed);
  }).toList();

  if (!preserveOrder) filtered.sort(_comparatorFor(view));
  return filtered;
}

int Function(Song, Song) _comparatorFor(LibraryView view) {
  final ascending = view.direction == SortDirection.ascending;
  return (a, b) {
    final result = _compareField(a, b, view.sortField, ascending: ascending);
    // Title breaks every tie, so a list never reshuffles between two builds
    // that happen to compare equal.
    return result != 0 ? result : _byText(a.title, b.title);
  };
}

int _compareField(
  Song a,
  Song b,
  LibrarySortField field, {
  required bool ascending,
}) {
  // The two nullable fields handle direction themselves: "unknown" has to
  // stay at the end whichever way the list is pointed, which flipping the
  // arguments would not do.
  switch (field) {
    case LibrarySortField.lastPlayed:
      return _compareNullable(
        a.lastPlayedAt,
        b.lastPlayedAt,
        ascending: ascending,
      );
    case LibrarySortField.dateAdded:
      return _compareNullable(a.dateAdded, b.dateAdded, ascending: ascending);
    case LibrarySortField.title:
    case LibrarySortField.artist:
    case LibrarySortField.album:
    case LibrarySortField.length:
    case LibrarySortField.playCount:
      final result = switch (field) {
        LibrarySortField.artist => _byText(a.artist, b.artist),
        LibrarySortField.album => _byText(a.album, b.album),
        LibrarySortField.length => a.duration.compareTo(b.duration),
        LibrarySortField.playCount => a.playCount.compareTo(b.playCount),
        _ => _byText(a.title, b.title),
      };
      return ascending ? result : -result;
  }
}

/// Compares two possibly-unknown values, keeping unknown last both ways.
///
/// A song the media store gave no date-added for, or one never played, has an
/// *unknown* value rather than an old one. Treating unknown as the epoch put
/// every song cached before those columns existed at the front of "Oldest
/// first"; sorting them last in both directions says "no answer" instead.
int _compareNullable<T extends Comparable<T>>(
  T? a,
  T? b, {
  required bool ascending,
}) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  final result = a.compareTo(b);
  return ascending ? result : -result;
}

int _byText(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());
