import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../data/models/song.dart';
import '../../../shared/widgets/app_search_field.dart';
import '../application/library_controller.dart';
import 'folder_songs_screen.dart';

/// Browse music using the device's actual folder structure (Screens.md #3),
/// searchable by folder name.
class FolderBrowserTab extends ConsumerStatefulWidget {
  const FolderBrowserTab({super.key});

  @override
  ConsumerState<FolderBrowserTab> createState() => _FolderBrowserTabState();
}

class _FolderBrowserTabState extends ConsumerState<FolderBrowserTab> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final library = ref.watch(libraryStreamProvider);

    return library.when(
      data: (songs) {
        final byFolder = <String, List<Song>>{};
        for (final song in songs) {
          byFolder.putIfAbsent(p.dirname(song.filePath), () => []).add(song);
        }
        if (byFolder.isEmpty) {
          return const Center(child: Text('No folders found yet.'));
        }

        final normalizedQuery = _query.trim().toLowerCase();
        final folders =
            byFolder.keys
                .where(
                  (folder) =>
                      normalizedQuery.isEmpty ||
                      p
                          .basename(folder)
                          .toLowerCase()
                          .contains(normalizedQuery),
                )
                .toList()
              ..sort();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: AppSearchField(
                hint: 'Search folders',
                onChanged: (query) => setState(() => _query = query),
              ),
            ),
            Expanded(
              child: folders.isEmpty
                  ? const Center(child: Text('No folders match your search.'))
                  : ListView.builder(
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
                                  FolderSongsScreen(folderPath: folder),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          Center(child: Text('Failed to load folders: $error')),
    );
  }
}
