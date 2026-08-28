import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/sleep_timer_controller.dart';

/// The action the user picked from [NowPlayingMoreSheet].
enum NowPlayingMoreAction {
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
  const NowPlayingMoreSheet({super.key, required this.canRemoveFromPlaylist});

  final bool canRemoveFromPlaylist;

  static Future<NowPlayingMoreAction?> show(
    BuildContext context, {
    required bool canRemoveFromPlaylist,
  }) {
    return showModalBottomSheet<NowPlayingMoreAction>(
      context: context,
      builder: (_) =>
          NowPlayingMoreSheet(canRemoveFromPlaylist: canRemoveFromPlaylist),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final sleepTimer = ref.watch(sleepTimerControllerProvider);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(
              Icons.bedtime_outlined,
              color: sleepTimer.isActive ? scheme.primary : null,
            ),
            title: const Text('Sleep timer'),
            subtitle: sleepTimer.isActive ? Text(_describe(sleepTimer)) : null,
            onTap: () =>
                Navigator.of(context).pop(NowPlayingMoreAction.sleepTimer),
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Share'),
            onTap: () => Navigator.of(context).pop(NowPlayingMoreAction.share),
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
