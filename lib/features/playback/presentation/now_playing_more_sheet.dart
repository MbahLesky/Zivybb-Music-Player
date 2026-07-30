import 'package:flutter/material.dart';

/// The action the user picked from [NowPlayingMoreSheet].
enum NowPlayingMoreAction {
  share,
  playbackSpeed,
  editTags,
  setRingtone,
  removeFromPlaylist,
  delete,
}

/// "More" options for the currently playing song, reached from the Now
/// Playing screen's bottom control row.
///
/// Purely presentational — it returns the chosen [NowPlayingMoreAction] (or
/// `null` if dismissed) rather than performing the action itself, so the
/// caller can act using its own long-lived `BuildContext`/`WidgetRef`
/// instead of the sheet's, which is gone as soon as it closes.
class NowPlayingMoreSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          ListTile(
            leading: Icon(Icons.delete_outline, color: scheme.error),
            title: Text(
              'Delete from library',
              style: TextStyle(color: scheme.error),
            ),
            onTap: () => Navigator.of(context).pop(NowPlayingMoreAction.delete),
          ),
        ],
      ),
    );
  }
}
