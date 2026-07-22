import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/album_art.dart';

/// The persistent player docked at the bottom of the library screens.
///
/// Collapses to nothing when no track is loaded so the library gets the full
/// height until playback actually starts.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playback = AppScope.playbackOf(context);

    return AnimatedBuilder(
      animation: playback,
      builder: (context, _) {
        final song = playback.currentSong;
        if (song == null) return const SizedBox.shrink();

        return Material(
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.nowPlaying),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: playback.progress,
                    minHeight: 2,
                    backgroundColor: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.2),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        AlbumArt(seed: song.id, size: 44),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyLarge,
                              ),
                              Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: playback.togglePlayPause,
                          icon: Icon(
                            playback.isPlaying ? Icons.pause : Icons.play_arrow,
                          ),
                          tooltip: playback.isPlaying ? 'Pause' : 'Play',
                        ),
                        IconButton(
                          onPressed: playback.next,
                          icon: const Icon(Icons.skip_next),
                          tooltip: 'Next',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
