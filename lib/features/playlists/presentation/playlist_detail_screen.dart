import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/playlist_repository.dart';
import '../../../shared/widgets/song_list_tile.dart';
import '../../playback/application/playback_controller.dart';
import '../application/playlist_controller.dart';
import 'add_songs_sheet.dart';

/// View and manage the songs within a specific playlist (Screens.md #5).
class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final String playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(playlistDetailProvider(playlistId));
    final songs = detail.value?.songs ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.value?.playlist.name ?? 'Playlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Add songs',
            onPressed: () => AddSongsSheet.show(
              context,
              playlistId,
              songs.map((song) => song.id).toSet(),
            ),
          ),
        ],
      ),
      body: detail.when(
        data: (value) {
          if (value == null) {
            return const Center(child: Text('Playlist not found.'));
          }
          if (value.songs.isEmpty) {
            return const Center(child: Text('No songs in this playlist yet.'));
          }
          return ReorderableListView.builder(
            itemCount: value.songs.length,
            onReorderItem: (oldIndex, newIndex) {
              final reordered = [...value.songs];
              final moved = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, moved);
              ref
                  .read(playlistRepositoryProvider)
                  .reorderSongs(
                    playlistId,
                    reordered.map((s) => s.id).toList(),
                  );
            },
            itemBuilder: (context, index) {
              final song = value.songs[index];
              return SongListTile(
                key: ValueKey(song.id),
                song: song,
                onTap: () => ref
                    .read(playbackControllerProvider.notifier)
                    .playQueue(value.songs, startIndex: index),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Remove from playlist',
                  onPressed: () => ref
                      .read(playlistRepositoryProvider)
                      .removeSong(playlistId, song.id),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load playlist: $error')),
      ),
      floatingActionButton: songs.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () => ref
                  .read(playbackControllerProvider.notifier)
                  .playQueue(songs, startIndex: 0),
              child: const Icon(Icons.play_arrow),
            ),
    );
  }
}
