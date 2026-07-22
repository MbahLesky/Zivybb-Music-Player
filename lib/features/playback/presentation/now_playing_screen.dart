import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/mood_tags.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../shared/widgets/album_art.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/mood_chip.dart';
import '../application/playback_controller.dart';

/// The full playback view for the current track.
///
/// The beat-reactive visualizer takes the place of the artwork block once the
/// audio analysis pipeline lands (Development Plan, Week 3).
class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  /// Position being dragged to, held locally so the thumb tracks the finger
  /// instead of snapping back to the engine's position on every tick.
  double? _scrubPosition;

  @override
  Widget build(BuildContext context) {
    final playback = AppScope.playbackOf(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: Navigator.of(context).pop,
          icon: const Icon(Icons.keyboard_arrow_down),
          tooltip: 'Back to library',
        ),
        title: const Text('Now Playing'),
      ),
      body: AnimatedBuilder(
        animation: playback,
        builder: (context, _) {
          final song = playback.currentSong;
          if (song == null) {
            return const EmptyState(
              icon: Icons.play_circle_outline,
              title: 'Nothing playing',
              message: 'Pick a song from your library to start.',
            );
          }

          final mood = MoodTags.byId(song.moodTagId);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) => AlbumArt(
                          seed: song.id,
                          size: constraints.biggest.shortestSide.clamp(
                            120.0,
                            320.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    song.title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${song.artist} · ${song.album}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (mood != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    MoodChip(tag: mood),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _ProgressBar(
                    playback: playback,
                    scrubPosition: _scrubPosition,
                    onScrub: (value) => setState(() => _scrubPosition = value),
                    onScrubEnd: (value) {
                      playback.seek(Duration(milliseconds: value.round()));
                      setState(() => _scrubPosition = null);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TransportControls(playback: playback),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.playback,
    required this.scrubPosition,
    required this.onScrub,
    required this.onScrubEnd,
  });

  final PlaybackController playback;
  final double? scrubPosition;
  final ValueChanged<double> onScrub;
  final ValueChanged<double> onScrubEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = playback.duration.inMilliseconds.toDouble();
    final current = (scrubPosition ?? playback.position.inMilliseconds)
        .toDouble()
        .clamp(0.0, total == 0 ? 1.0 : total);

    return Column(
      children: [
        Slider(
          value: current,
          max: total == 0 ? 1 : total,
          onChanged: onScrub,
          onChangeEnd: onScrubEnd,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatTrackDuration(Duration(milliseconds: current.round())),
                style: theme.textTheme.bodySmall,
              ),
              Text(
                formatTrackDuration(playback.duration),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransportControls extends StatelessWidget {
  const _TransportControls({required this.playback});

  final PlaybackController playback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: playback.toggleShuffle,
          icon: const Icon(Icons.shuffle),
          color: playback.isShuffleEnabled ? theme.colorScheme.primary : null,
          tooltip: playback.isShuffleEnabled ? 'Shuffle on' : 'Shuffle off',
        ),
        IconButton(
          onPressed: playback.previous,
          iconSize: 36,
          icon: const Icon(Icons.skip_previous),
          tooltip: 'Previous',
        ),
        IconButton.filled(
          onPressed: playback.togglePlayPause,
          iconSize: 40,
          padding: const EdgeInsets.all(AppSpacing.md),
          icon: Icon(playback.isPlaying ? Icons.pause : Icons.play_arrow),
          tooltip: playback.isPlaying ? 'Pause' : 'Play',
        ),
        IconButton(
          onPressed: playback.next,
          iconSize: 36,
          icon: const Icon(Icons.skip_next),
          tooltip: 'Next',
        ),
        _LikeButton(playback: playback),
      ],
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.playback});

  final PlaybackController playback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final library = AppScope.libraryOf(context);
    final song = playback.currentSong;
    if (song == null) return const SizedBox.shrink();

    return IconButton(
      onPressed: () async {
        playback.syncSong(await library.toggleLiked(song));
      },
      icon: Icon(song.isLiked ? Icons.favorite : Icons.favorite_border),
      color: song.isLiked ? theme.colorScheme.secondary : null,
      tooltip: song.isLiked ? 'Remove from Liked' : 'Add to Liked',
    );
  }
}
