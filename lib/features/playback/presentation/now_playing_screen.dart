import 'dart:io';
import 'dart:math' as math;

// Flutter's own animation `RepeatMode` (repeating_animation_builder.dart) is
// hidden here since it collides with our playback `RepeatMode` — nothing in
// this app uses the animation one.
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/audio_player_service.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/song.dart';
import '../../../data/repositories/playlist_repository.dart';
import '../../../data/repositories/song_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_bar_icon_action.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/seek_step_icon.dart';
import '../../../shared/widgets/song_artwork.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/vibe_chips.dart';
import '../../game/presentation/rhythm_game_screen.dart';
import '../../library/presentation/song_delete_actions.dart';
import '../../playlists/presentation/save_to_playlist_sheet.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/presentation/equalizer_screen.dart';
import '../../tag_editor/presentation/tag_editor_screen.dart';
import '../../vibe_tagging/presentation/vibe_tagging_screen.dart';
import '../../visualizer/presentation/fullscreen_visualizer_screen.dart';
import '../../visualizer/presentation/wave_visualizer.dart';
import '../application/playback_controller.dart';
import 'now_playing_more_sheet.dart';
import 'queue_screen.dart';
import 'sleep_timer_sheet.dart';

const _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

/// Full playback experience for the current track.
///
/// Fills the whole view: artwork/visualizer flex in the middle and the
/// controls anchor at the bottom — one main transport row (seek-back /
/// previous / play / next / seek-forward, with the seek step configurable in
/// Settings ▸ Playback) and one secondary row (shuffle / repeat / like /
/// save / vibes / more). Everything else — share, speed, edit tags, ringtone,
/// remove, delete — lives in the "more" sheet, and the queue and full-screen
/// visualizer sit in the app bar.
class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackControllerProvider);
    final song = playback.currentSong;
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    // Watched separately so the like state reflects live edits, since
    // `song` is a snapshot taken when the queue was loaded.
    final liveSong = song == null
        ? null
        : ref.watch(songStreamProvider(song.id)).value ?? song;
    final isLiked = liveSong?.isLiked ?? song?.isLiked ?? false;
    final seekSeconds = settings.seekStep.inSeconds;

    return Scaffold(
      appBar: GradientAppBar(
        title: const Text('Now Playing'),
        actions: [
          AppBarIconAction(
            icon: const Icon(Icons.timelapse),
            iconColor: playback.previewModeEnabled
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
            tooltip: playback.previewModeEnabled
                ? 'Preview mode on (30s clips)'
                : 'Preview mode off',
            onPressed: () => ref
                .read(playbackControllerProvider.notifier)
                .togglePreviewMode(),
          ),
          AppBarIconAction(
            icon: const Icon(Icons.videogame_asset_outlined),
            tooltip: 'Rhythm mode',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                settings: const RouteSettings(name: AppRoutes.rhythmGame),
                builder: (_) => const RhythmGameScreen(),
              ),
            ),
          ),
          AppBarIconAction(
            icon: const Icon(Icons.queue_music),
            tooltip: 'Queue',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                settings: const RouteSettings(name: AppRoutes.queue),
                builder: (_) => const QueueScreen(),
              ),
            ),
          ),
          AppBarIconAction(
            icon: const Icon(Icons.fullscreen),
            tooltip: 'Full-screen visualizer',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                settings: const RouteSettings(
                  name: AppRoutes.fullScreenVisualizer,
                ),
                builder: (_) => const FullScreenVisualizerScreen(),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.surface(Theme.of(context).colorScheme),
        ),
        child: song == null
            ? const Center(child: Text('Nothing is playing.'))
            : SafeArea(
                // Fills the whole view — media flexes in the middle and the
                // controls pin to the bottom — falling back to scrolling
                // only when the viewport is too short to fit the controls
                // (e.g. landscape).
                child: LayoutBuilder(
                  builder: (context, viewport) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewport.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                          child: Column(
                            children: [
                              Expanded(child: _MediaCenterpiece(song: song)),
                              const SizedBox(height: 16),
                              Text(
                                song.title,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${song.artist} — ${song.album}',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: VibeChips(
                                  songId: song.id,
                                  compact: false,
                                ),
                              ),
                              const _CrossfadeIndicator(),
                              const SizedBox(height: 8),
                              _ProgressBar(
                                position: playback.position,
                                duration: playback.duration,
                                showVisualizer:
                                    settings.visualizerPlacement ==
                                    VisualizerPlacement.seekBar,
                                onSeek: (value) => ref
                                    .read(playbackControllerProvider.notifier)
                                    .seek(value),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _format(playback.position),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                    Text(
                                      _format(playback.duration),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Main transport: the play button as the single
                              // large control, flanked by track skips and the
                              // configurable seek-step jumps.
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    iconSize: 28,
                                    icon: SeekStepIcon(
                                      seconds: seekSeconds,
                                      forward: false,
                                    ),
                                    tooltip: 'Back ${seekSeconds}s',
                                    onPressed: () => ref
                                        .read(
                                          playbackControllerProvider.notifier,
                                        )
                                        .seekBy(-settings.seekStep),
                                  ),
                                  IconButton(
                                    iconSize: 36,
                                    icon: const Icon(Icons.skip_previous),
                                    tooltip: 'Previous',
                                    onPressed: () => ref
                                        .read(
                                          playbackControllerProvider.notifier,
                                        )
                                        .previous(),
                                  ),
                                  GradientFab(
                                    size: 72,
                                    icon: playback.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    tooltip: playback.isPlaying
                                        ? 'Pause'
                                        : 'Play',
                                    onPressed: () => ref
                                        .read(
                                          playbackControllerProvider.notifier,
                                        )
                                        .togglePlayPause(),
                                  ),
                                  IconButton(
                                    iconSize: 36,
                                    icon: const Icon(Icons.skip_next),
                                    tooltip: 'Next',
                                    onPressed: () => ref
                                        .read(
                                          playbackControllerProvider.notifier,
                                        )
                                        .next(),
                                  ),
                                  IconButton(
                                    iconSize: 28,
                                    icon: SeekStepIcon(
                                      seconds: seekSeconds,
                                      forward: true,
                                    ),
                                    tooltip: 'Forward ${seekSeconds}s',
                                    onPressed: () => ref
                                        .read(
                                          playbackControllerProvider.notifier,
                                        )
                                        .seekBy(settings.seekStep),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Secondary row: playback modes and utilities;
                              // everything else is in the "more" sheet.
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      playback.shuffleEnabled
                                          ? Icons.shuffle_on_outlined
                                          : Icons.shuffle,
                                    ),
                                    color: playback.shuffleEnabled
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                    tooltip: playback.shuffleEnabled
                                        ? 'Shuffle on'
                                        : 'Shuffle off',
                                    onPressed: () => ref
                                        .read(
                                          playbackControllerProvider.notifier,
                                        )
                                        .toggleShuffle(),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      playback.repeatMode == RepeatMode.one
                                          ? Icons.repeat_one
                                          : Icons.repeat,
                                    ),
                                    color: playback.repeatMode == RepeatMode.off
                                        ? null
                                        : Theme.of(context).colorScheme.primary,
                                    tooltip: switch (playback.repeatMode) {
                                      RepeatMode.off => 'Repeat off',
                                      RepeatMode.all => 'Repeat all',
                                      RepeatMode.one => 'Repeat one',
                                    },
                                    onPressed: () => ref
                                        .read(
                                          playbackControllerProvider.notifier,
                                        )
                                        .cycleRepeatMode(),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                    ),
                                    tooltip: isLiked ? 'Unlike' : 'Like',
                                    onPressed: () => ref
                                        .read(songRepositoryProvider)
                                        .setLiked(song.id, !isLiked),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.playlist_add),
                                    tooltip: 'Save to playlist',
                                    onPressed: () =>
                                        SaveToPlaylistSheet.show(context, song),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.mood),
                                    tooltip: 'Tag vibes',
                                    onPressed: () =>
                                        VibeTaggingSheet.show(context, song),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_horiz),
                                    tooltip: 'More',
                                    onPressed: () => _showMoreMenu(
                                      context,
                                      ref,
                                      song,
                                      playback.sourcePlaylistId,
                                    ),
                                  ),
                                ],
                              ),
                              if (settings.visualizerPlacement ==
                                  VisualizerPlacement.belowControls) ...[
                                const SizedBox(height: 16),
                                WaveVisualizer(
                                  color: ref.watch(visualizerColorProvider),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showSpeedPicker(BuildContext context, WidgetRef ref, double current) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final speed in _speedOptions)
              ListTile(
                title: Text('${speed}x'),
                trailing: speed == current ? const Icon(Icons.check) : null,
                onTap: () {
                  ref.read(playbackControllerProvider.notifier).setSpeed(speed);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMoreMenu(
    BuildContext context,
    WidgetRef ref,
    Song song,
    String? sourcePlaylistId,
  ) async {
    final action = await NowPlayingMoreSheet.show(
      context,
      canRemoveFromPlaylist: sourcePlaylistId != null,
    );
    if (!context.mounted || action == null) return;

    switch (action) {
      case NowPlayingMoreAction.sleepTimer:
        await SleepTimerSheet.show(context);
      case NowPlayingMoreAction.share:
        await SharePlus.instance.share(
          ShareParams(text: 'Listening to "${song.title}" by ${song.artist}'),
        );
      case NowPlayingMoreAction.playbackSpeed:
        _showSpeedPicker(
          context,
          ref,
          ref.read(playbackControllerProvider).speed,
        );
      case NowPlayingMoreAction.editTags:
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => TagEditorScreen(song: song)));
      case NowPlayingMoreAction.equalizer:
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const EqualizerScreen()));
      case NowPlayingMoreAction.setRingtone:
        await _setAsRingtone(context, song);
      case NowPlayingMoreAction.removeFromPlaylist:
        if (sourcePlaylistId != null) {
          await ref
              .read(playlistRepositoryProvider)
              .removeSong(sourcePlaylistId, song.id);
        }
      case NowPlayingMoreAction.removeFromLibrary:
        if (await confirmAndRemoveFromLibrary(context, ref, song)) {
          await _skipPastDeleted(ref);
        }
      case NowPlayingMoreAction.deleteFromDevice:
        if (await confirmAndDeleteFromDevice(context, ref, song)) {
          await _skipPastDeleted(ref);
        }
    }
  }

  /// Moves off a song that has just left the library, so Now Playing isn't
  /// left showing a track that no longer exists.
  Future<void> _skipPastDeleted(WidgetRef ref) async {
    try {
      await ref.read(playbackControllerProvider.notifier).next();
    } catch (_) {
      // Nothing left to skip to.
    }
  }

  Future<void> _setAsRingtone(BuildContext context, Song song) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final granted = await RingtoneSet.isWriteSettingsGranted;
      if (!granted) {
        if (!context.mounted) return;
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission needed'),
            content: const Text(
              'Setting a ringtone needs the "Modify system settings" '
              'permission. Open Settings and enable it for Zivybb, then '
              'try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Open settings'),
              ),
            ],
          ),
        );
        if (openSettings == true) await openAppSettings();
        return;
      }

      final success = await RingtoneSet.setRingtoneFromFile(
        File(song.filePath),
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(success ? 'Set as ringtone' : 'Could not set ringtone'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not set ringtone: $e')),
      );
    }
  }
}

/// Artwork and/or visualizer, centered in whatever vertical space the
/// transport controls leave over.
///
/// Which of the two appears is [VisualizerPlacement]'s call: the visualizer
/// can take the artwork's slot outright, sit in a slim band beneath it, or
/// stay out of this area entirely.
class _MediaCenterpiece extends ConsumerWidget {
  const _MediaCenterpiece({required this.song});

  final Song song;

  /// Height of the band drawn under the artwork. Deliberately short — the
  /// artwork above it is the main event in that placement.
  static const _underArtworkHeight = 64.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    final placement = settings.visualizerPlacement;
    // Sized from the screen rather than a LayoutBuilder because this sits
    // inside an IntrinsicHeight, which LayoutBuilder doesn't support; the
    // FittedBox below absorbs any squeeze from short viewports.
    final screen = MediaQuery.sizeOf(context);
    final artSize = math.min(screen.width - 72, screen.height * 0.30);
    final showsArtworkSlot =
        settings.showAlbumArtInNowPlaying || !placement.showsArtwork;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showsArtworkSlot)
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: placement.showsArtwork
                  ? SongArtwork(
                      song: song,
                      size: artSize,
                      borderRadius: 20,
                      iconSize: 64,
                      // Only handed a visualizer when the user asked for the
                      // fallback; otherwise the icon placeholder stands.
                      fallback: settings.visualizerAsArtworkFallback
                          ? _ArtworkSlotVisualizer(size: artSize)
                          : null,
                    )
                  : _ArtworkSlotVisualizer(size: artSize),
            ),
          ),
        if (placement == VisualizerPlacement.underArtwork) ...[
          if (showsArtworkSlot) const SizedBox(height: 12),
          WaveVisualizer(
            color: ref.watch(visualizerColorProvider),
            height: _underArtworkHeight,
          ),
        ],
      ],
    );
  }
}

/// The visualizer filling a square artwork slot, matching the artwork's
/// rounded corners and tinted plate so the swap reads as a substitution
/// rather than a hole in the layout.
class _ArtworkSlotVisualizer extends ConsumerWidget {
  const _ArtworkSlotVisualizer({required this.size});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(
        child: WaveVisualizer(
          color: ref.watch(visualizerColorProvider),
          // The square slot suits the radial styles as they are, and gives
          // the bar styles a taller-than-usual band to fill.
          height: size,
        ),
      ),
    );
  }
}

/// The seek slider, optionally drawn over the visualizer.
///
/// The visualizer sits behind the slider rather than replacing it: the bar's
/// job is still to show progress and to scrub, and a row of bars conveys
/// neither. It is wrapped in [IgnorePointer] so every touch reaches the
/// slider underneath it in the hit-test order.
class _ProgressBar extends ConsumerWidget {
  const _ProgressBar({
    required this.position,
    required this.duration,
    required this.showVisualizer,
    required this.onSeek,
  });

  final Duration position;
  final Duration duration;
  final bool showVisualizer;
  final ValueChanged<Duration> onSeek;

  static const _height = 56.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final slider = Slider(
      min: 0,
      max: duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1,
      value: position.inMilliseconds
          .clamp(0, duration.inMilliseconds)
          .toDouble(),
      onChanged: (value) => onSeek(Duration(milliseconds: value.round())),
    );

    if (!showVisualizer) return slider;

    return SizedBox(
      height: _height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.6,
                  child: WaveVisualizer(
                    color: ref.watch(visualizerColorProvider),
                    height: _height,
                  ),
                ),
              ),
            ),
          ),
          SliderTheme(
            // A thin track and a solid thumb, so the slider stays readable
            // as a control against the moving picture behind it.
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              activeTrackColor: scheme.primary,
              inactiveTrackColor: scheme.onSurface.withValues(alpha: 0.28),
              thumbColor: scheme.primary,
            ),
            child: slider,
          ),
        ],
      ),
    );
  }
}

class _CrossfadeIndicator extends ConsumerWidget {
  const _CrossfadeIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStreamProvider).value;
    if (settings == null || !settings.crossfadeEnabled) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.compare_arrows,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            'Crossfade ${settings.crossfadeDuration.inSeconds}s',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
