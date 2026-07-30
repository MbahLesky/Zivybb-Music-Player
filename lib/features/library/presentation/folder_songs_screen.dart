import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../data/models/song.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/song_list_tile.dart';
import '../../playback/application/playback_controller.dart';

enum _DurationFilter { all, underOneMinute, oneMinuteOrMore }

/// Songs within a single device folder, with a duration sort/filter control
/// (SRS F-2.3: sort by duration, e.g. above or below one minute).
class FolderSongsScreen extends StatefulWidget {
  const FolderSongsScreen({
    super.key,
    required this.folderPath,
    required this.songs,
  });

  final String folderPath;
  final List<Song> songs;

  @override
  State<FolderSongsScreen> createState() => _FolderSongsScreenState();
}

class _FolderSongsScreenState extends State<FolderSongsScreen> {
  _DurationFilter _filter = _DurationFilter.all;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.songs.where((song) {
      return switch (_filter) {
        _DurationFilter.all => true,
        _DurationFilter.underOneMinute =>
          song.duration < const Duration(minutes: 1),
        _DurationFilter.oneMinuteOrMore =>
          song.duration >= const Duration(minutes: 1),
      };
    }).toList();

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: GradientAppBar(
        title: Text(p.basename(widget.folderPath)),
        actions: [
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
      body: filtered.isEmpty
          ? const Center(child: Text('No songs match this filter.'))
          : Consumer(
              builder: (context, ref, _) => ListView.builder(
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
    );
  }
}
