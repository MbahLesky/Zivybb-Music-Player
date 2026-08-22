import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/core/services/media_delete_service.dart';
import 'package:zivybb/core/services/media_scanner_service.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/models/song.dart';
import 'package:zivybb/data/repositories/song_repository.dart';

/// Reports a fixed outcome, standing in for the Android side.
class _FakeMediaDelete implements MediaDeleteService {
  _FakeMediaDelete(this.outcome);

  final MediaDeleteOutcome outcome;
  final requested = <String>[];

  @override
  Future<MediaDeleteOutcome> deleteSong(Song song) async {
    requested.add(song.id);
    return outcome;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedScanner implements MediaScannerService {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Song _song({String id = 'a', bool isVideo = false}) => Song(
  id: id,
  filePath: '/music/$id.mp3',
  title: 'A',
  artist: 'Artist',
  album: 'Album',
  duration: const Duration(seconds: 30),
  isVideo: isVideo,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('mediaStoreIdOf', () {
    test('passes an audio id through unchanged', () {
      expect(mediaStoreIdOf(_song(id: '4212')), '4212');
    });

    test('strips the namespace off a video id', () {
      // The platform needs the raw media-store row id back; isVideo is what
      // picks the collection it belongs to.
      expect(
        mediaStoreIdOf(_song(id: '${videoSongIdPrefix}77', isVideo: true)),
        '77',
      );
    });
  });

  group('MediaDeleteService', () {
    const channel = MethodChannel('com.lespa.zivybb/media_delete');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    Future<MediaDeleteOutcome> outcomeFor(
      Future<Object?> Function(MethodCall) handler,
    ) {
      messenger.setMockMethodCallHandler(channel, handler);
      return MediaDeleteService(channel: channel).deleteSong(_song());
    }

    test('maps the platform answers onto outcomes', () async {
      expect(
        await outcomeFor((_) async => 'deleted'),
        MediaDeleteOutcome.deleted,
      );
      expect(
        await outcomeFor((_) async => 'denied'),
        MediaDeleteOutcome.denied,
      );
      expect(
        await outcomeFor((_) async => 'failed'),
        MediaDeleteOutcome.failed,
      );
    });

    test('an unrecognised answer counts as a failure', () async {
      expect(await outcomeFor((_) async => null), MediaDeleteOutcome.failed);
    });

    test('a platform error is reported, not thrown', () async {
      expect(
        await outcomeFor((_) async => throw PlatformException(code: 'nope')),
        MediaDeleteOutcome.failed,
      );
    });

    test('no handler at all means unsupported', () async {
      // The state on iOS, desktop, and in a plain unit test: no method
      // channel is registered, so the library must be left alone rather than
      // an error being shown.
      expect(
        await MediaDeleteService(channel: channel).deleteSong(_song()),
        MediaDeleteOutcome.unsupported,
      );
    });

    test('sends the raw media-store id and the video flag', () async {
      MethodCall? seen;
      messenger.setMockMethodCallHandler(channel, (call) async {
        seen = call;
        return 'deleted';
      });

      await MediaDeleteService(
        channel: channel,
      ).deleteSong(_song(id: '${videoSongIdPrefix}9', isVideo: true));

      expect(seen?.method, 'deleteSong');
      expect(seen?.arguments['id'], '9');
      expect(seen?.arguments['isVideo'], isTrue);
    });
  });

  group('SongRepository.deleteFromDevice', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.connect(NativeDatabase.memory());
      await database
          .into(database.songs)
          .insert(
            SongsCompanion.insert(
              id: 'a',
              filePath: '/music/a.mp3',
              title: 'A',
              artist: 'Artist',
              album: 'Album',
              durationMs: 30000,
            ),
          );
    });
    tearDown(() => database.close());

    Future<MediaDeleteOutcome> deleteWith(MediaDeleteOutcome outcome) {
      return SongRepository(
        database: database,
        scanner: _UnusedScanner(),
        mediaDelete: _FakeMediaDelete(outcome),
      ).deleteFromDevice(_song());
    }

    Future<int> songCount() async =>
        (await database.select(database.songs).get()).length;

    test('drops the library row once the file is gone', () async {
      expect(
        await deleteWith(MediaDeleteOutcome.deleted),
        MediaDeleteOutcome.deleted,
      );
      expect(await songCount(), 0);
    });

    test('keeps the song when the user declines the system dialog', () async {
      // The file is still on the device, so removing the row would hide a
      // song the user can still play — and lose its likes and vibes with it.
      expect(
        await deleteWith(MediaDeleteOutcome.denied),
        MediaDeleteOutcome.denied,
      );
      expect(await songCount(), 1);
    });

    test('keeps the song when the delete fails or is unsupported', () async {
      expect(
        await deleteWith(MediaDeleteOutcome.failed),
        MediaDeleteOutcome.failed,
      );
      expect(await songCount(), 1);

      expect(
        await deleteWith(MediaDeleteOutcome.unsupported),
        MediaDeleteOutcome.unsupported,
      );
      expect(await songCount(), 1);
    });

    test('clears playlist entries and vibes along with the song', () async {
      await database
          .into(database.vibeTags)
          .insert(
            VibeTagsCompanion.insert(
              id: 'chill',
              label: 'Chill',
              colorHex: '#4FC3F7',
            ),
          );
      await database
          .into(database.playlists)
          .insert(
            PlaylistsCompanion.insert(
              id: 'p',
              name: 'Mix',
              createdAt: DateTime(2026),
            ),
          );
      await database
          .into(database.playlistSongs)
          .insert(
            PlaylistSongsCompanion.insert(
              playlistId: 'p',
              songId: 'a',
              position: 0,
            ),
          );
      await database
          .into(database.songVibes)
          .insert(SongVibesCompanion.insert(songId: 'a', vibeTagId: 'chill'));

      await deleteWith(MediaDeleteOutcome.deleted);

      expect(await database.select(database.playlistSongs).get(), isEmpty);
      expect(await database.select(database.songVibes).get(), isEmpty);
    });
  });
}
