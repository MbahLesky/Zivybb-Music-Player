import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/song.dart';

/// What came of asking the platform to delete a song's file.
enum MediaDeleteOutcome {
  /// The file is gone from the device.
  deleted,

  /// The user dismissed Android's own delete confirmation. Nothing changed,
  /// and this is not an error to report as one.
  denied,

  /// No platform handler — a non-Android build, or a test.
  unsupported,

  /// The delete was attempted and failed (permission, read-only volume, a
  /// file the media store no longer knows about).
  failed,
}

/// Deletes a song's underlying file from the device.
///
/// This is deliberately not `dart:io`'s `File.delete`. From Android 10 on,
/// scoped storage means an app cannot touch media files it did not create,
/// and from Android 11 the only route is [MediaStore.createDeleteRequest],
/// which shows Android's *own* confirmation dialog and reports back through
/// an activity result. So the work happens on the platform side and this
/// class is the thin Dart end of it.
///
/// That system dialog is also why [MediaDeleteOutcome.denied] exists and is
/// treated as an ordinary outcome: on Android 11+ the user gets a second say
/// after Zivybb's own confirmation, and changing their mind there must leave
/// the library untouched.
class MediaDeleteService {
  MediaDeleteService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'com.lespa.zivybb/media_delete';

  final MethodChannel _channel;

  /// Asks the platform to delete [song]'s file, returning what happened.
  ///
  /// Never throws: every failure mode maps to an outcome, because the caller
  /// has to decide whether to drop the library row and that decision is the
  /// same whether the platform said "no" or fell over.
  Future<MediaDeleteOutcome> deleteSong(Song song) async {
    final String? outcome;
    try {
      outcome = await _channel.invokeMethod<String>('deleteSong', {
        'id': mediaStoreIdOf(song),
        'isVideo': song.isVideo,
        'filePath': song.filePath,
      });
    } on MissingPluginException {
      return MediaDeleteOutcome.unsupported;
    } on PlatformException {
      return MediaDeleteOutcome.failed;
    }

    return switch (outcome) {
      'deleted' => MediaDeleteOutcome.deleted,
      'denied' => MediaDeleteOutcome.denied,
      _ => MediaDeleteOutcome.failed,
    };
  }
}

/// The bare media-store row id behind [song], with the video namespace
/// prefix stripped.
///
/// Videos and audio tracks live in separately-numbered MediaStore
/// collections, so `MediaScannerService` prefixes video ids to keep them
/// apart in the library — but the platform delete needs the raw number back,
/// paired with [Song.isVideo] to pick the right collection.
String mediaStoreIdOf(Song song) {
  return song.id.startsWith(videoSongIdPrefix)
      ? song.id.substring(videoSongIdPrefix.length)
      : song.id;
}

final mediaDeleteServiceProvider = Provider<MediaDeleteService>(
  (ref) => MediaDeleteService(),
);
