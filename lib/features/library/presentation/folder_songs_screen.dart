import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/utils/song_search.dart';
import '../../../data/models/song.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/mini_player.dart';
import '../../../shared/widgets/play_shuffle_header.dart';
import '../../../shared/widgets/song_list_tile.dart';
import '../../playback/application/playback_controller.dart';
import '../../library/application/library_controller.dart';

enum _DurationFilter { all, underOneMinute, oneMinuteOrMore }

enum _SongSort { folderOrder, title, artist, duration }

/// Songs within a single device folder, with play/shuffle-all header
/// actions, search, sort, and a duration sort/filter control (SRS F-2.3:
/// sort by duration, e.g. above or below one minute).
///
/// The folder's songs are re-derived from the live library rather than kept
/// as the snapshot passed in: liking a track here, or editing its tags, has
/// to be reflected on the row that was just tapped.
class FolderSongsScreen extends ConsumerStatefulWidget {
  const FolderSongsScreen({super.key, required this.folderPath});

  final String folderPath;

  @override
  ConsumerState<FolderSongsScreen> createState() => _FolderSongsScreenState();
}

class _FolderSongsScreenState extends ConsumerState<FolderSongsScreen> {
  _DurationFilter _filter = _DurationFilter.all;
  _SongSort _sort = _SongSort.folderOrder;
  String _query = '';

  List<Song> _visibleSongs(List<Song> folderSongs) {
    final songs = folderSongs.where((song) {
      final durationOk = switch (_filter) {
        _DurationFilter.all => true,
        _DurationFilter.underOneMinute =>
          song.duration < const Duration(minutes: 1),
        _DurationFilter.oneMinuteOrMore =>
          song.duration >= const Duration(minutes: 1),
      };
      return durationOk && songMatchesQuery(song, _query);
    }).toList();

    switch (_sort) {
      case _SongSort.folderOrder:
        break;
      case _SongSort.title:
        songs.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case _SongSort.artist:
        songs.sort(
          (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        );
      case _SongSort.duration:
        songs.sort((a, b) => a.duration.compareTo(b.duration));
    }
    return songs;
  }

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryStreamProvider).value ?? const <Song>[];
    final folderSongs = [
      for (final song in library)
        if (p.dirname(song.filePath) == widget.folderPath) song,
    ];
    final filtered = _visibleSongs(folderSongs);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: const MiniPlayer(),
      appBar: GradientAppBar(
        title: Text(p.basename(widget.folderPath)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<_SongSort>(
              icon: Icon(Icons.sort, color: scheme.primary),
              tooltip: 'Sort',
              initialValue: _sort,
              onSelected: (value) => setState(() => _sort = value),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: _SongSort.folderOrder,
                  child: Text('Folder order'),
                ),
                PopupMenuItem(value: _SongSort.title, child: Text('Title')),
                PopupMenuItem(value: _SongSort.artist, child: Text('Artist')),
                PopupMenuItem(value: _SongSort.duration, child: Text('Length')),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: scheme.surface,
              shape: BoxShape.circle,
            ),
            child: PopupMenuButton<_DurationFilter>(
              icon: Icon(Icons.filter_list, color: scheme.primary),
              tooltip: 'Filter by duration',
              initialValue: _filter,
              onSelected: (value) => setState(() => _filter = value),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: _DurationFilter.all,
                  child: Text('All durations'),
                ),
                PopupMenuItem(
                  value: _DurationFilter.underOneMinute,
                  child: Text('Under 1 minute'),
                ),
                PopupMenuItem(
                  value: _DurationFilter.oneMinuteOrMore,
                  child: Text('1 minute or more'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          PlayShuffleHeader(songs: filtered),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: AppSearchField(
              hint: 'Search in folder',
              onChanged: (query) => setState(() => _query = query),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No songs match.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final song = filtered[index];
                      return SongListTile(
                        song: song,
                        onTap: () => ref
                            .read(playbackControllerProvider.notifier)
                            .playQueue(filtered, startIndex: index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
