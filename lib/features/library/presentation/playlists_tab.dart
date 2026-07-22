import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/album_art.dart';
import '../application/mood_playlist.dart';

/// Playlists, starting with the ones Zivybb generates from mood tags.
///
/// Hand-made playlists arrive with the playlist editor (Development Plan,
/// Week 2); until then this tab shows only the auto-generated set.
class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final library = AppScope.libraryOf(context);
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: library,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.md,
            AppSpacing.screenHorizontal,
            AppSpacing.md,
          ),
          children: [
            Text('From your moods', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            if (library.moodPlaylists.isEmpty)
              Text(
                'Tag a few songs with a mood and they will collect here.',
                style: theme.textTheme.bodySmall,
              )
            else
              for (final playlist in library.moodPlaylists) ...[
                _MoodPlaylistCard(playlist: playlist),
                const SizedBox(height: AppSpacing.sm),
              ],
            const SizedBox(height: AppSpacing.lg),
            Text('Your playlists', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'None yet. Building your own playlists is the next piece of '
              'the library.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}

class _MoodPlaylistCard extends StatelessWidget {
  const _MoodPlaylistCard({required this.playlist});

  final MoodPlaylist playlist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playback = AppScope.playbackOf(context);
    final songCount = playlist.songs.length;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => playback.playQueue(playlist.songs),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              AlbumArt(
                seed: playlist.tag.id,
                size: 56,
                icon: Icons.auto_awesome,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(playlist.tag.label, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 2),
                    Text(
                      '$songCount ${songCount == 1 ? 'song' : 'songs'} · '
                      'Auto',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => playback.playQueue(playlist.songs),
                icon: const Icon(Icons.play_arrow),
                tooltip: 'Play ${playlist.tag.label}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
