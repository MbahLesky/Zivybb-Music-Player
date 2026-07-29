import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/gradient_card.dart';
import '../../playback/application/playback_controller.dart';
import '../../playlists/presentation/save_to_playlist_sheet.dart';
import '../application/discovery_controller.dart';

/// Surfaces lesser-played tracks from artists already in the library
/// (SRS F-4.3, Screens.md #8).
class SongDiscoveryScreen extends ConsumerWidget {
  const SongDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(discoveryControllerProvider);

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'New picks',
            onPressed: () =>
                ref.read(discoveryControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: feed.when(
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(
              child: Text('Play a few songs to unlock discovery picks.'),
            );
          }
          return RefreshIndicator(
            onRefresh: () =>
                ref.read(discoveryControllerProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return GradientCard(
                  onTap: () => ref
                      .read(playbackControllerProvider.notifier)
                      .playQueue(songs, startIndex: index),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${song.artist} — ${song.album}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        tooltip: 'Play',
                        onPressed: () => ref
                            .read(playbackControllerProvider.notifier)
                            .playQueue(songs, startIndex: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.playlist_add),
                        tooltip: 'Add to playlist',
                        onPressed: () =>
                            SaveToPlaylistSheet.show(context, song),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load discovery feed: $error')),
      ),
    );
  }
}
