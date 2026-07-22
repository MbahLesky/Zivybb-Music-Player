import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../shared/widgets/empty_state.dart';
import '../application/folder_group.dart';
import 'song_list_view.dart';

/// The library grouped by the device's own folder structure.
class FolderBrowserTab extends StatelessWidget {
  const FolderBrowserTab({super.key});

  @override
  Widget build(BuildContext context) {
    final library = AppScope.libraryOf(context);

    return AnimatedBuilder(
      animation: library,
      builder: (context, _) {
        if (library.folders.isEmpty) {
          return const EmptyState(
            icon: Icons.folder_outlined,
            title: 'No folders yet',
            message: 'Folders appear here once the library has been scanned.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: library.folders.length,
          itemBuilder: (context, index) =>
              _FolderTile(folder: library.folders[index]),
        );
      },
    );
  }
}

class _FolderTile extends StatelessWidget {
  const _FolderTile({required this.folder});

  final FolderGroup folder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final songCount = folder.songs.length;

    return ExpansionTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(folder.name, style: theme.textTheme.bodyLarge),
      subtitle: Text(
        '$songCount ${songCount == 1 ? 'song' : 'songs'} · '
        '${formatTrackDuration(folder.totalDuration)}',
        style: theme.textTheme.bodySmall,
      ),
      childrenPadding: const EdgeInsets.only(bottom: 8),
      children: [
        SongListView(
          songs: folder.songs,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
        ),
      ],
    );
  }
}
