import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/media_delete_service.dart';
import '../../../data/models/song.dart';
import '../../../data/repositories/song_repository.dart';

/// The two ways a song can leave the library, shared by every screen that
/// offers them so the wording and the confirmations stay identical.
///
/// They are deliberately kept distinct in the UI rather than merged behind
/// one "delete": removing a song from Zivybb is reversible by rescanning,
/// deleting its file is not, and a user reaching for the first should never
/// get the second.

/// Asks for confirmation, then deletes [song]'s file from the device and
/// drops it from the library.
///
/// Returns whether the file was actually deleted — callers on the Now
/// Playing screen use that to decide whether to skip to the next track.
///
/// The confirmation here is Zivybb's own. On Android 11+ the system shows a
/// second one of its own and the user can still back out there, which is why
/// this reports back rather than assuming success.
Future<bool> confirmAndDeleteFromDevice(
  BuildContext context,
  WidgetRef ref,
  Song song,
) async {
  final scheme = Theme.of(context).colorScheme;
  // Captured before the dialog: the caller may well be a tile that the
  // delete itself removes from the tree, so [context] can't be relied on
  // once the awaits below have run.
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete "${song.title}" from device?'),
      content: const Text(
        'This permanently deletes the file from your device, along with its '
        'likes, vibes, and playlist entries. It cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(foregroundColor: scheme.error),
          child: const Text('Delete file'),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;

  final outcome = await ref.read(songRepositoryProvider).deleteFromDevice(song);

  final message = switch (outcome) {
    MediaDeleteOutcome.deleted => 'Deleted "${song.title}" from your device',
    // The user declined the system's own dialog. Saying nothing would read
    // as the app having ignored them, so this confirms nothing changed.
    MediaDeleteOutcome.denied => 'Nothing was deleted',
    MediaDeleteOutcome.unsupported =>
      'Deleting files is only supported on Android',
    MediaDeleteOutcome.failed => 'Could not delete "${song.title}"',
  };
  messenger.showSnackBar(SnackBar(content: Text(message)));

  return outcome == MediaDeleteOutcome.deleted;
}

/// Asks for confirmation, then removes [song] from Zivybb's library while
/// leaving the file on the device.
///
/// Returns whether the song was removed.
Future<bool> confirmAndRemoveFromLibrary(
  BuildContext context,
  WidgetRef ref,
  Song song,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Remove "${song.title}"?'),
      content: const Text(
        'This removes the song from your library. The file on your device is '
        'not deleted, so a rescan will find it again.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Remove'),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;

  await ref.read(songRepositoryProvider).deleteFromLibrary(song.id);
  return true;
}
