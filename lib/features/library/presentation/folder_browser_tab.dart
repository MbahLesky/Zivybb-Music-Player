import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../data/models/song.dart';
import '../application/library_controller.dart';
import 'folder_songs_screen.dart';

/// Browse music using the device's actual folder structure (Screens.md #3).
class FolderBrowserTab extends ConsumerWidget {
  const FolderBrowserTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryStreamProvider);

    return library.when(
      data: (songs) {
        final byFolder = <String, List<Song>>{};
        for (final song in songs) {
          byFolder.putIfAbsent(p.dirname(song.filePath), () => []).add(song);
        }
        final folders = byFolder.keys.toList()..sort();

        if (folders.isEmpty) {
          return const Center(child: Text('No folders found yet.'));
        }

        return ListView.builder(
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folder = folders[index];
            final folderSongs = byFolder[folder]!;
            return ListTile(
              leading: const Icon(Icons.folder),
              title: Text(p.basename(folder)),
              subtitle: Text(
                '${folderSongs.length} song${folderSongs.length == 1 ? '' : 's'}',
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      FolderSongsScreen(folderPath: folder, songs: folderSongs),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Failed to load folders: $error')),
    );
  }
}
