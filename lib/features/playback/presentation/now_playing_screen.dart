import 'dart:io';

// Flutter's own animation `RepeatMode` (repeating_animation_builder.dart) is
// hidden here since it collides with our playback `RepeatMode` — nothing in
// this app uses the animation one.
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:on_audio_query_pluse/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ringtone_set_plus/ringtone_set_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/audio_player_service.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../data/models/app_settings.dart';
import '../../../data/models/mood_tag.dart';
import '../../../data/models/song.dart';
import '../../../data/repositories/playlist_repository.dart';
import '../../../data/repositories/song_repository.dart';
import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_bar_icon_action.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../mood_tagging/application/mood_tagging_controller.dart';
import '../../mood_tagging/presentation/mood_tagging_screen.dart';
import '../../playlists/presentation/save_to_playlist_sheet.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/presentation/equalizer_screen.dart';
import '../../tag_editor/presentation/tag_editor_screen.dart';
import '../../visualizer/presentation/fullscreen_visualizer_screen.dart';
import '../../visualizer/presentation/wave_visualizer.dart';
import '../application/playback_controller.dart';
import 'now_playing_more_sheet.dart';

const _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

/// Full playback experience for the current track.
///
/// Laid out minimally: artwork/visualizer as the centerpiece, track info
/// beneath it, then one full transport row (shuffle/previous/play/next/
/// repeat) and one short utility row (like/save/mood/more). Everything
/// else — share, speed, edit tags, ringtone, remove, delete — lives in the
/// "more" sheet, and the full-screen visualizer sits in the app bar.
class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playback = ref.watch(playbackControllerProvider);
    final song = playback.currentSong;
    final settings =
        ref.watch(settingsStreamProvider).value ?? const AppSettings();
    // Watched separately so the mood tag badge reflects live edits, since
    // `song` is a snapshot taken when the queue was loaded.
    final liveSong = song == null
        ? null
        : ref.watch(songStreamProvider(song.id)).value ?? song;
    final isLiked = liveSong?.isLiked ?? song?.isLiked ?? false;

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
            icon: const Icon(Icons.equalizer),
            tooltip: 'Equalizer',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const EqualizerScreen())),
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
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    if (settings.showAlbumArtInNowPlaying) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: QueryArtworkWidget(
                          id: int.parse(song.id),
                          type: ArtworkType.AUDIO,
                          artworkWidth: 200,
                          artworkHeight: 200,
                          artworkFit: BoxFit.cover,
                          nullArtworkWidget: Container(
                            width: 200,
                            height: 200,
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.music_note,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (settings.showVisualizerInNowPlaying) ...[
                      WaveVisualizer(color: ref.watch(visualizerColorProvider)),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      song.title,
                      style: Theme.of(context).textTheme.headlineSmall,
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
                    if (liveSong?.moodTagId != null) ...[
                      const SizedBox(height: 8),
                      _MoodTagLabel(moodTagId: liveSong!.moodTagId!),
                    ],
                    const _CrossfadeIndicator(),
                    const SizedBox(height: 8),
                    Slider(
                      min: 0,
                      max: playback.duration.inMilliseconds > 0
                          ? playback.duration.inMilliseconds.toDouble()
                          : 1,
                      value: playback.position.inMilliseconds
                          .clamp(0, playback.duration.inMilliseconds)
                          .toDouble(),
                      onChanged: (value) => ref
                          .read(playbackControllerProvider.notifier)
                          .seek(Duration(milliseconds: value.round())),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _format(playback.position),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            _format(playback.duration),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Full transport in one row, the play button as the
                    // single large control.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          iconSize: 28,
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
                              .read(playbackControllerProvider.notifier)
                              .toggleShuffle(),
                        ),
                        IconButton(
                          iconSize: 36,
                          icon: const Icon(Icons.skip_previous),
                          tooltip: 'Previous',
                          onPressed: () => ref
                              .read(playbackControllerProvider.notifier)
                              .previous(),
                        ),
                        GradientFab(
                          size: 72,
                          icon: playback.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          tooltip: playback.isPlaying ? 'Pause' : 'Play',
                          onPressed: () => ref
                              .read(playbackControllerProvider.notifier)
                              .togglePlayPause(),
                        ),
                        IconButton(
                          iconSize: 36,
                          icon: const Icon(Icons.skip_next),
                          tooltip: 'Next',
                          onPressed: () => ref
                              .read(playbackControllerProvider.notifier)
                              .next(),
                        ),
                        IconButton(
                          iconSize: 28,
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
                              .read(playbackControllerProvider.notifier)
                              .cycleRepeatMode(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Short utility row; everything else is in the sheet.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
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
                          tooltip: 'Tag mood',
                          onPressed: () => MoodTaggingSheet.show(context, song),
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
                  ],
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
      case NowPlayingMoreAction.setRingtone:
        await _setAsRingtone(context, song);
      case NowPlayingMoreAction.removeFromPlaylist:
        if (sourcePlaylistId != null) {
          await ref
              .read(playlistRepositoryProvider)
              .removeSong(sourcePlaylistId, song.id);
        }
      case NowPlayingMoreAction.delete:
        await _confirmAndDelete(context, ref, song);
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

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    Song song,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${song.title}"?'),
        content: const Text(
          'This removes the song from your library. The file on your '
          'device is not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(songRepositoryProvider).deleteFromLibrary(song.id);
    try {
      await ref.read(playbackControllerProvider.notifier).next();
    } catch (_) {
      // Nothing left to skip to.
    }
  }
}

class _MoodTagLabel extends ConsumerWidget {
  const _MoodTagLabel({required this.moodTagId});

  final String moodTagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(moodTagsStreamProvider).value ?? const [];
    MoodTag? match;
    for (final tag in tags) {
      if (tag.id == moodTagId) {
        match = tag;
        break;
      }
    }
    if (match == null) return const SizedBox.shrink();
    return Chip(label: Text(match.label), visualDensity: VisualDensity.compact);
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
