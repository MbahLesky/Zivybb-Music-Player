import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_player_service.dart';
import '../../../data/repositories/song_repository.dart';
import '../application/playback_controller.dart';
import '../application/sleep_timer_controller.dart';

/// The action the user picked from [NowPlayingMoreSheet].
enum NowPlayingMoreAction {
  toggleLike,
  saveToPlaylist,
  toggleShuffle,
  cycleRepeat,
  sleepTimer,
  share,
  playbackSpeed,
  editTags,
  equalizer,
  setRingtone,
  removeFromPlaylist,
  removeFromLibrary,
  deleteFromDevice,
}

/// "More" options for the currently playing song, reached from the Now
/// Playing screen's bottom control row.
///
/// Purely presentational — it returns the chosen [NowPlayingMoreAction] (or
/// `null` if dismissed) rather than performing the action itself, so the
/// caller can act using its own long-lived `BuildContext`/`WidgetRef`
/// instead of the sheet's, which is gone as soon as it closes.
class NowPlayingMoreSheet extends ConsumerWidget {
  const NowPlayingMoreSheet({
    super.key,
    required this.canRemoveFromPlaylist,
    this.showTransportExtras = false,
  });

  final bool canRemoveFromPlaylist;

  /// Whether to carry the controls the compact layout leaves off the screen
  /// — like, save to playlist, shuffle and repeat. Listed here only when
  /// they have nowhere else to be, so the full layout's sheet isn't padded
  /// with duplicates of buttons already on view.
  final bool showTransportExtras;

  static Future<NowPlayingMoreAction?> show(
    BuildContext context, {
    required bool canRemoveFromPlaylist,
    bool showTransportExtras = false,
  }) {
    return showModalBottomSheet<NowPlayingMoreAction>(
      context: context,
      // The list runs past the default half-height once the compact
      // layout's extras are in it, and a sheet that can be dragged up is
      // better than one that clips its last entries.
      isScrollControlled: true,
      builder: (_) => NowPlayingMoreSheet(
        canRemoveFromPlaylist: canRemoveFromPlaylist,
        showTransportExtras: showTransportExtras,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final sleepTimer = ref.watch(sleepTimerControllerProvider);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            if (showTransportExtras) ...[
              const _TransportExtras(),
              const Divider(height: 1),
            ],
            ListTile(
              leading: Icon(
                Icons.bedtime_outlined,
                color: sleepTimer.isActive ? scheme.primary : null,
              ),
              title: const Text('Sleep timer'),
              subtitle: sleepTimer.isActive
                  ? Text(_describe(sleepTimer))
                  : null,
              onTap: () =>
                  Navigator.of(context).pop(NowPlayingMoreAction.sleepTimer),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () =>
                  Navigator.of(context).pop(NowPlayingMoreAction.share),
            ),
            ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Playback speed'),
              onTap: () =>
                  Navigator.of(context).pop(NowPlayingMoreAction.playbackSpeed),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit tags'),
              onTap: () =>
                  Navigator.of(context).pop(NowPlayingMoreAction.editTags),
            ),
            ListTile(
              leading: const Icon(Icons.equalizer),
              title: const Text('Equalizer'),
              onTap: () =>
                  Navigator.of(context).pop(NowPlayingMoreAction.equalizer),
            ),
            ListTile(
              leading: const Icon(Icons.ring_volume),
              title: const Text('Set as ringtone'),
              onTap: () =>
                  Navigator.of(context).pop(NowPlayingMoreAction.setRingtone),
            ),
            if (canRemoveFromPlaylist)
              ListTile(
                leading: const Icon(Icons.playlist_remove),
                title: const Text('Remove from playlist'),
                onTap: () => Navigator.of(
                  context,
                ).pop(NowPlayingMoreAction.removeFromPlaylist),
              ),
            // Two separate entries rather than one "delete": taking a song out
            // of Zivybb is undone by a rescan, deleting its file is not, and
            // the subtitles are what keep the two from being confused.
            ListTile(
              leading: const Icon(Icons.playlist_remove_outlined),
              title: const Text('Remove from library'),
              subtitle: const Text('Keeps the file on your device'),
              onTap: () => Navigator.of(
                context,
              ).pop(NowPlayingMoreAction.removeFromLibrary),
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_outlined, color: scheme.error),
              title: Text(
                'Delete from device',
                style: TextStyle(color: scheme.error),
              ),
              subtitle: const Text('Deletes the file permanently'),
              onTap: () => Navigator.of(
                context,
              ).pop(NowPlayingMoreAction.deleteFromDevice),
            ),
          ],
        ),
      ),
    );
  }

  String _describe(SleepTimerState timer) {
    final remaining = timer.remaining!;
    if (remaining == Duration.zero) return 'Pausing when this track ends';
    final minutes = remaining.inMinutes;
    return minutes >= 1
        ? 'Pausing in $minutes min'
        : 'Pausing in ${remaining.inSeconds} sec';
  }
}

/// The buttons the compact Now Playing layout leaves off the screen, shown
/// here with their current state so the sheet says what shuffle and repeat
/// are actually set to.
class _TransportExtras extends ConsumerWidget {
  const _TransportExtras();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final playback = ref.watch(playbackControllerProvider);
    final song = playback.currentSong;
    // Watched separately for the same reason Now Playing does: the queue
    // holds a snapshot, so its like state goes stale.
    final isLiked = song == null
        ? false
        : ref.watch(songStreamProvider(song.id)).value?.isLiked ?? song.isLiked;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? scheme.primary : null,
          ),
          title: Text(isLiked ? 'Unlike' : 'Like'),
          onTap: () =>
              Navigator.of(context).pop(NowPlayingMoreAction.toggleLike),
        ),
        ListTile(
          leading: const Icon(Icons.playlist_add),
          title: const Text('Save to playlist'),
          onTap: () =>
              Navigator.of(context).pop(NowPlayingMoreAction.saveToPlaylist),
        ),
        ListTile(
          leading: Icon(
            playback.shuffleEnabled ? Icons.shuffle_on_outlined : Icons.shuffle,
            color: playback.shuffleEnabled ? scheme.primary : null,
          ),
          title: const Text('Shuffle'),
          subtitle: Text(playback.shuffleEnabled ? 'On' : 'Off'),
          onTap: () =>
              Navigator.of(context).pop(NowPlayingMoreAction.toggleShuffle),
        ),
        ListTile(
          leading: Icon(
            playback.repeatMode == RepeatMode.one
                ? Icons.repeat_one
                : Icons.repeat,
            color: playback.repeatMode == RepeatMode.off
                ? null
                : scheme.primary,
          ),
          title: const Text('Repeat'),
          subtitle: Text(switch (playback.repeatMode) {
            RepeatMode.off => 'Off',
            RepeatMode.all => 'All',
            RepeatMode.one => 'This track',
          }),
          onTap: () =>
              Navigator.of(context).pop(NowPlayingMoreAction.cycleRepeat),
        ),
      ],
    );
  }
}
