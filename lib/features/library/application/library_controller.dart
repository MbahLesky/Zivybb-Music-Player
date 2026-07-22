import 'package:flutter/foundation.dart';

import '../../../core/constants/mood_tags.dart';
import '../../../data/models/song.dart';
import '../../../data/repositories/song_repository.dart';
import 'folder_group.dart';
import 'mood_playlist.dart';

/// Loads the library and exposes the groupings the library screen renders.
///
/// Grouping happens once per load rather than in `build()` so scrolling the
/// song list never re-walks the whole library.
class LibraryController extends ChangeNotifier {
  LibraryController({required SongRepository repository})
    : _repository = repository;

  final SongRepository _repository;

  bool _isLoading = true;
  List<Song> _songs = const [];
  List<FolderGroup> _folders = const [];
  List<MoodPlaylist> _moodPlaylists = const [];

  bool get isLoading => _isLoading;
  List<Song> get songs => _songs;
  List<FolderGroup> get folders => _folders;
  List<MoodPlaylist> get moodPlaylists => _moodPlaylists;

  List<Song> get likedSongs =>
      _songs.where((song) => song.isLiked).toList(growable: false);

  List<Song> get missingSongs =>
      _songs.where((song) => song.isMissing).toList(growable: false);

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _songs = await _repository.loadSongs();
    _regroup();

    _isLoading = false;
    notifyListeners();
  }

  /// Flips the liked state of [song] and returns the updated record so callers
  /// can keep their own copies (such as the playback queue) in sync.
  Future<Song> toggleLiked(Song song) async {
    final updated = await _repository.setLiked(song, isLiked: !song.isLiked);

    final index = _songs.indexWhere((candidate) => candidate.id == song.id);
    if (index != -1) {
      _songs = List.of(_songs)..[index] = updated;
      _regroup();
      notifyListeners();
    }

    return updated;
  }

  void _regroup() {
    _folders = _groupByFolder(_songs);
    _moodPlaylists = _groupByMood(_songs);
  }

  static List<FolderGroup> _groupByFolder(List<Song> songs) {
    final byPath = <String, List<Song>>{};
    for (final song in songs) {
      byPath.putIfAbsent(song.folderPath, () => []).add(song);
    }

    final groups = byPath.entries
        .map(
          (entry) => FolderGroup(
            path: entry.key,
            name: entry.value.first.folderName,
            songs: entry.value,
          ),
        )
        .toList();
    groups.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return groups;
  }

  static List<MoodPlaylist> _groupByMood(List<Song> songs) {
    final playlists = <MoodPlaylist>[];
    for (final tag in MoodTags.presets) {
      final tagged = songs
          .where((song) => song.moodTagId == tag.id)
          .toList(growable: false);
      if (tagged.isNotEmpty) {
        playlists.add(MoodPlaylist(tag: tag, songs: tagged));
      }
    }

    return playlists;
  }
}
