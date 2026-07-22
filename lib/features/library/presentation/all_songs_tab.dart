import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../shared/widgets/empty_state.dart';
import 'song_list_view.dart';

/// Every song in the library, newest scan order.
class AllSongsTab extends StatelessWidget {
  const AllSongsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final library = AppScope.libraryOf(context);

    return AnimatedBuilder(
      animation: library,
      builder: (context, _) {
        if (library.songs.isEmpty) {
          return const EmptyState(
            icon: Icons.library_music_outlined,
            title: 'No songs yet',
            message:
                'Nothing was found on this device. '
                'Run a scan once storage access is granted.',
          );
        }

        return SongListView(
          songs: library.songs,
          padding: const EdgeInsets.symmetric(vertical: 8),
        );
      },
    );
  }
}
