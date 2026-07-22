import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../playback/presentation/mini_player.dart';
import 'song_list_view.dart';

/// Quick access to everything the user has liked.
class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = AppScope.libraryOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Liked')),
      bottomNavigationBar: const MiniPlayer(),
      body: AnimatedBuilder(
        animation: library,
        builder: (context, _) {
          final liked = library.likedSongs;
          if (liked.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: 'Nothing liked yet',
              message: 'Tap the heart on any song to keep it here.',
            );
          }

          return SongListView(
            songs: liked,
            padding: const EdgeInsets.symmetric(vertical: 8),
          );
        },
      ),
    );
  }
}
