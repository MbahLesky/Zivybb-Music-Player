import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/playlist_repository.dart';
import '../../library/application/library_controller.dart';

/// Lets the user add library songs to a playlist (Screens.md #5: "add/remove
/// songs"). Stays open after each tap so multiple songs can be added.
class AddSongsSheet extends ConsumerWidget {
  const AddSongsSheet({
    super.key,
    required this.playlistId,
    required this.existingSongIds,
  });

  final String playlistId;
  final Set<String> existingSongIds;

  static Future<void> show(
    BuildContext context,
    String playlistId,
    Set<String> existingSongIds,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddSongsSheet(
        playlistId: playlistId,
        existingSongIds: existingSongIds,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryStreamProvider);

    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollController) => library.when(
        data: (songs) {
          final available = songs
              .where((song) => !existingSongIds.contains(song.id))
              .toList();

          if (available.isEmpty) {
            return const Center(
              child: Text('All songs are already in this playlist.'),
            );
          }

          return ListView.builder(
            controller: scrollController,
            itemCount: available.length,
            itemBuilder: (context, index) {
              final song = available[index];
              return ListTile(
                title: Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.add),
                onTap: () => ref
                    .read(playlistRepositoryProvider)
                    .addSong(playlistId, song.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load songs: $error')),
      ),
    );
  }
}
