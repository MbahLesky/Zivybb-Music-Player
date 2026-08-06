import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zivybb/core/services/audio_player_service.dart';
import 'package:zivybb/core/services/media_scanner_service.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/repositories/playback_session_repository.dart';
import 'package:zivybb/data/repositories/playlist_repository.dart';
import 'package:zivybb/data/repositories/song_repository.dart';
import 'package:zivybb/data/repositories/vibe_tag_repository.dart';
import 'package:zivybb/features/playlists/application/vibe_playlist_generator.dart';

/// Inserts a song straight into the cache, bypassing the device scan so the
/// tests never touch a platform channel.
Future<void> _insertSong(
  AppDatabase database, {
  required String id,
  String title = 'Song',
  String artist = 'Artist',
  String album = 'Album',
  int durationMs = 180000,
  String? vibeTagId,
}) async {
  await database
      .into(database.songs)
      .insert(
        SongsCompanion.insert(
          id: id,
          filePath: '/music/$id.mp3',
          title: title,
          artist: artist,
          album: album,
          durationMs: durationMs,
        ),
      );
  // Vibes are a join now, so tagging is a second row rather than a column.
  if (vibeTagId != null) {
    await database
        .into(database.songVibes)
        .insert(SongVibesCompanion.insert(songId: id, vibeTagId: vibeTagId));
  }
}

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.connect(NativeDatabase.memory()));
  tearDown(() => database.close());

  group('PlaylistRepository', () {
    late PlaylistRepository repository;

    setUp(() => repository = PlaylistRepository(database: database));

    test('keeps songs in the order they were added', () async {
      await _insertSong(database, id: 'a', title: 'Alpha');
      await _insertSong(database, id: 'b', title: 'Bravo');
      await _insertSong(database, id: 'c', title: 'Charlie');

      final playlist = await repository.createPlaylist('Road trip');
      await repository.addSong(playlist.id, 'a');
      await repository.addSong(playlist.id, 'b');
      await repository.addSong(playlist.id, 'c');

      final detail = await repository.watchPlaylistWithSongs(playlist.id).first;
      expect(detail!.songs.map((song) => song.id), ['a', 'b', 'c']);
    });

    test('reorderSongs persists the new order', () async {
      await _insertSong(database, id: 'a');
      await _insertSong(database, id: 'b');
      await _insertSong(database, id: 'c');

      final playlist = await repository.createPlaylist('Mix');
      await repository.addSong(playlist.id, 'a');
      await repository.addSong(playlist.id, 'b');
      await repository.addSong(playlist.id, 'c');

      await repository.reorderSongs(playlist.id, ['c', 'a', 'b']);

      final detail = await repository.watchPlaylistWithSongs(playlist.id).first;
      expect(detail!.songs.map((song) => song.id), ['c', 'a', 'b']);
    });

    test('adding the same song twice does not duplicate it', () async {
      await _insertSong(database, id: 'a');
      final playlist = await repository.createPlaylist('Mix');

      await repository.addSong(playlist.id, 'a');
      await repository.addSong(playlist.id, 'a');

      final detail = await repository.watchPlaylistWithSongs(playlist.id).first;
      expect(detail!.songs, hasLength(1));
    });

    test('removeSong drops only the named song', () async {
      await _insertSong(database, id: 'a');
      await _insertSong(database, id: 'b');
      final playlist = await repository.createPlaylist('Mix');
      await repository.addSong(playlist.id, 'a');
      await repository.addSong(playlist.id, 'b');

      await repository.removeSong(playlist.id, 'a');

      final detail = await repository.watchPlaylistWithSongs(playlist.id).first;
      expect(detail!.songs.map((song) => song.id), ['b']);
    });

    // Guards the fix for foreign keys never having been enforced: leftover
    // membership rows would reappear inside a playlist as soon as a device
    // rescan reused the deleted song's media-store ID.
    test('deleting a playlist clears its membership rows', () async {
      await _insertSong(database, id: 'a');
      final playlist = await repository.createPlaylist('Temp');
      await repository.addSong(playlist.id, 'a');

      await repository.deletePlaylist(playlist.id);

      final leftovers = await database.select(database.playlistSongs).get();
      expect(leftovers, isEmpty);
    });

    test('deleting a song clears it from every playlist', () async {
      await _insertSong(database, id: 'a');
      await _insertSong(database, id: 'b');
      final first = await repository.createPlaylist('One');
      final second = await repository.createPlaylist('Two');
      await repository.addSong(first.id, 'a');
      await repository.addSong(second.id, 'a');
      await repository.addSong(second.id, 'b');

      await SongRepository(
        database: database,
        scanner: MediaScannerService(),
      ).deleteFromLibrary('a');

      final remaining = await database.select(database.playlistSongs).get();
      expect(remaining.map((row) => row.songId), ['b']);
    });

    test('allManualPlaylistsWithSongs excludes auto-generated mixes', () async {
      await _insertSong(database, id: 'a');
      await repository.createPlaylist('Manual');
      await database
          .into(database.vibeTags)
          .insert(
            VibeTagsCompanion.insert(
              id: 'chill',
              label: 'Chill',
              colorHex: '#4FC3F7',
            ),
          );
      await repository.replaceAutoPlaylistSongs(
        sourceVibeTagId: 'chill',
        name: 'Chill Mix',
        songIds: ['a'],
      );

      final manual = await repository.allManualPlaylistsWithSongs();
      expect(manual.map((entry) => entry.playlist.name), ['Manual']);
    });
  });

  group('VibeTagRepository', () {
    late VibeTagRepository repository;

    setUp(() => repository = VibeTagRepository(database: database));

    test('ensureSeeded seeds once and preserves preset order', () async {
      await repository.ensureSeeded();
      await repository.ensureSeeded();

      final tags = await repository.watchVibeTags().first;
      expect(tags.map((tag) => tag.id), [
        'energetic',
        'chill',
        'happy',
        'sad',
        'angry',
        'relaxed',
      ]);
    });

    test('created tags land after the seeded presets', () async {
      await repository.ensureSeeded();
      final created = await repository.createVibeTag('Focus', '#26A69A');

      final tags = await repository.watchVibeTags().first;
      expect(tags.last.id, created.id);
      expect(tags.last.label, 'Focus');
    });

    test('rename and recolor update in place', () async {
      await repository.ensureSeeded();

      await repository.renameVibeTag('chill', 'Mellow');
      await repository.recolorVibeTag('chill', '#123456');

      final tags = await repository.watchVibeTags().first;
      final chill = tags.firstWhere((tag) => tag.id == 'chill');
      expect(chill.label, 'Mellow');
      expect(chill.colorHex, '#123456');
    });

    test('reorderVibeTags rewrites the sort order', () async {
      await repository.ensureSeeded();

      await repository.reorderVibeTags([
        'relaxed',
        'angry',
        'sad',
        'happy',
        'chill',
        'energetic',
      ]);

      final tags = await repository.watchVibeTags().first;
      expect(tags.first.id, 'relaxed');
      expect(tags.last.id, 'energetic');
    });

    test('a song can carry several vibes at once', () async {
      await repository.ensureSeeded();
      await _insertSong(database, id: 'a');

      await repository.addVibeToSong('a', 'chill');
      await repository.addVibeToSong('a', 'happy');

      expect(await repository.watchVibeIdsForSong('a').first, {
        'chill',
        'happy',
      });

      await repository.removeVibeFromSong('a', 'chill');
      expect(await repository.watchVibeIdsForSong('a').first, {'happy'});
    });
  });

  group('VibePlaylistGenerator', () {
    late VibePlaylistGenerator generator;
    late PlaylistRepository playlists;
    late VibeTagRepository vibeTags;

    setUp(() {
      playlists = PlaylistRepository(database: database);
      vibeTags = VibeTagRepository(database: database);
      generator = VibePlaylistGenerator(
        vibeTagRepository: vibeTags,
        playlistRepository: playlists,
      );
    });

    test('regenerateAll builds one mix per tag that has songs', () async {
      await vibeTags.ensureSeeded();
      await _insertSong(database, id: 'a', vibeTagId: 'chill');
      await _insertSong(database, id: 'b', vibeTagId: 'chill');

      await generator.regenerateAll();

      final all = await playlists.watchPlaylists().first;
      final auto = all.where((playlist) => playlist.isAutoGenerated).toList();
      expect(auto, hasLength(1));
      expect(auto.single.name, 'Chill Mix');
    });

    test('a song with several vibes lands in each of their mixes', () async {
      await vibeTags.ensureSeeded();
      await _insertSong(database, id: 'a', vibeTagId: 'chill');
      await vibeTags.addVibeToSong('a', 'happy');

      await generator.regenerateAll();

      final auto = (await playlists.watchPlaylists().first)
          .where((playlist) => playlist.isAutoGenerated)
          .map((playlist) => playlist.name)
          .toSet();
      expect(auto, {'Chill Mix', 'Happy Mix'});
    });

    test('regenerateAll drops a mix once its last song is untagged', () async {
      await vibeTags.ensureSeeded();
      await _insertSong(database, id: 'a', vibeTagId: 'chill');
      await generator.regenerateAll();

      await vibeTags.removeVibeFromSong('a', 'chill');
      await generator.regenerateAll();

      final all = await playlists.watchPlaylists().first;
      expect(all.where((playlist) => playlist.isAutoGenerated), isEmpty);
    });

    // The tag's `onDelete: setNull` foreign key clears `sourceVibeTagId`, so
    // deleting the tag first would leave the mix behind with nothing left to
    // identify it by. This is the regression that ordering guards against.
    test('deleteVibeTag removes the tag and its auto playlist', () async {
      await vibeTags.ensureSeeded();
      await _insertSong(database, id: 'a', vibeTagId: 'chill');
      await generator.regenerateAll();
      expect(await playlists.watchPlaylists().first, hasLength(1));

      await generator.deleteVibeTag('chill');

      expect(await playlists.watchPlaylists().first, isEmpty);
      final tags = await vibeTags.watchVibeTags().first;
      expect(tags.any((tag) => tag.id == 'chill'), isFalse);
    });

    test('deleting a tag untags its songs rather than deleting them', () async {
      await vibeTags.ensureSeeded();
      await _insertSong(database, id: 'a', vibeTagId: 'chill');

      await generator.deleteVibeTag('chill');

      final songs = await SongRepository(
        database: database,
        scanner: MediaScannerService(),
      ).allSongs();
      expect(songs, hasLength(1));
      expect(await vibeTags.watchVibeIdsForSong('a').first, isEmpty);
    });
  });

  group('SongRepository', () {
    late SongRepository repository;

    setUp(
      () => repository = SongRepository(
        database: database,
        scanner: MediaScannerService(),
      ),
    );

    test('recordPlayed increments the count and stamps the time', () async {
      await _insertSong(database, id: 'a');

      await repository.recordPlayed('a');
      await repository.recordPlayed('a');

      final song = (await repository.allSongs()).single;
      expect(song.playCount, 2);
      expect(song.lastPlayedAt, isNotNull);
    });

    test('updateMetadata edits the cached tags', () async {
      await _insertSong(database, id: 'a', title: 'Old');

      await repository.updateMetadata(
        'a',
        title: 'New',
        artist: 'Someone',
        album: 'Record',
      );

      final song = (await repository.allSongs()).single;
      expect(song.title, 'New');
      expect(song.artist, 'Someone');
      expect(song.album, 'Record');
    });

    test(
      'taggedOrLikedSongs returns liked or vibe-tagged songs only',
      () async {
        await database
            .into(database.vibeTags)
            .insert(
              VibeTagsCompanion.insert(
                id: 'chill',
                label: 'Chill',
                colorHex: '#4FC3F7',
              ),
            );
        await _insertSong(database, id: 'plain');
        await _insertSong(database, id: 'tagged', vibeTagId: 'chill');
        await _insertSong(database, id: 'liked');
        await repository.setLiked('liked', true);

        // Which songs carry a vibe comes from the join table, so the caller
        // passes it in rather than it being readable off the song row.
        final vibeTagged = await VibeTagRepository(
          database: database,
        ).allSongVibeIds();
        final backupWorthy = await repository.taggedOrLikedSongs(
          vibeTagged.keys.toSet(),
        );
        expect(backupWorthy.map((song) => song.id).toSet(), {
          'tagged',
          'liked',
        });
      },
    );
  });

  group('PlaybackSessionRepository', () {
    late PlaybackSessionRepository repository;

    setUp(() => repository = PlaybackSessionRepository(database: database));

    test('load returns null before anything has been saved', () async {
      expect(await repository.load(), isNull);
    });

    test('save then load round-trips the queue and transport state', () async {
      await repository.save(
        const PlaybackSession(
          songIds: ['a', 'b', 'c'],
          currentIndex: 1,
          position: Duration(seconds: 42),
          shuffleEnabled: true,
          repeatMode: RepeatMode.all,
          speed: 1.25,
        ),
      );

      final session = (await repository.load())!;
      expect(session.songIds, ['a', 'b', 'c']);
      expect(session.currentIndex, 1);
      expect(session.position, const Duration(seconds: 42));
      expect(session.shuffleEnabled, isTrue);
      expect(session.repeatMode, RepeatMode.all);
      expect(session.speed, 1.25);
      expect(session.currentSongId, 'b');
    });

    test('saving again overwrites the single stored session', () async {
      await repository.save(
        const PlaybackSession(
          songIds: ['a'],
          currentIndex: 0,
          position: Duration.zero,
          shuffleEnabled: false,
          repeatMode: RepeatMode.off,
          speed: 1,
        ),
      );
      await repository.save(
        const PlaybackSession(
          songIds: ['x', 'y'],
          currentIndex: 1,
          position: Duration(seconds: 5),
          shuffleEnabled: false,
          repeatMode: RepeatMode.one,
          speed: 1,
        ),
      );

      final session = (await repository.load())!;
      expect(session.songIds, ['x', 'y']);
      expect(session.repeatMode, RepeatMode.one);
    });

    test('currentSongId is null when the index is out of range', () async {
      await repository.save(
        const PlaybackSession(
          songIds: [],
          currentIndex: 3,
          position: Duration.zero,
          shuffleEnabled: false,
          repeatMode: RepeatMode.off,
          speed: 1,
        ),
      );

      expect((await repository.load())!.currentSongId, isNull);
    });
  });
}
