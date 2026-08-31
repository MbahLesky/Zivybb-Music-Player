import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/core/services/media_scanner_service.dart';
import 'package:zivybb/core/services/video_query_service.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/models/song.dart';
import 'package:zivybb/data/repositories/song_repository.dart';

/// Stands in for the real scanner so the library logic can be exercised
/// without a device media store.
class _FakeScanner implements MediaScannerService {
  _FakeScanner({required this.audio, required this.videos});

  final List<Song> audio;
  final List<Song> videos;

  @override
  Future<bool> hasLibraryAccess() async => true;

  @override
  Future<List<Song>> scanLibrary({bool includeVideos = false}) async {
    return includeVideos ? [...audio, ...videos] : audio;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Song _audioSong(String id, String title) => Song(
  id: id,
  filePath: '/music/$title.mp3',
  title: title,
  artist: 'Artist',
  album: 'Album',
  duration: const Duration(minutes: 3),
);

Song _videoSong(String id, String title) => Song(
  id: '$videoSongIdPrefix$id',
  filePath: '/movies/$title.mp4',
  title: title,
  artist: 'Artist',
  album: 'Videos',
  duration: const Duration(minutes: 2, seconds: 30),
  isVideo: true,
);

void main() {
  // The video-query fallback test reaches a platform channel, which needs a
  // binding even though no handler is registered for it.
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUp(() => database = AppDatabase.connect(NativeDatabase.memory()));
  tearDown(() => database.close());

  SongRepository repositoryWith(_FakeScanner scanner) =>
      SongRepository(database: database, scanner: scanner);

  test('videos are scanned in only when the setting is on', () async {
    final scanner = _FakeScanner(
      audio: [_audioSong('1', 'Song')],
      videos: [_videoSong('9', 'Clip')],
    );
    final repository = repositoryWith(scanner);

    await repository.refreshFromDevice();
    var library = await repository.allSongs();
    expect(library.map((s) => s.title), ['Song']);

    await repository.refreshFromDevice(includeVideos: true);
    library = await repository.allSongs();
    expect(library.map((s) => s.title), containsAll(['Song', 'Clip']));
    expect(
      library.firstWhere((s) => s.title == 'Clip').isVideo,
      isTrue,
      reason: 'the video flag drives the badge and the artwork fallback',
    );
  });

  test('turning videos off clears them and their references', () async {
    final scanner = _FakeScanner(
      audio: [_audioSong('1', 'Song')],
      videos: [_videoSong('9', 'Clip')],
    );
    final repository = repositoryWith(scanner);
    await repository.refreshFromDevice(includeVideos: true);

    final videoId = '${videoSongIdPrefix}9';
    await database
        .into(database.vibeTags)
        .insert(
          VibeTagsCompanion.insert(id: 'v', label: 'Vibe', colorHex: '#FFF'),
        );
    await database
        .into(database.songVibes)
        .insert(SongVibesCompanion.insert(songId: videoId, vibeTagId: 'v'));
    await database
        .into(database.playlists)
        .insert(
          PlaylistsCompanion.insert(
            id: 'p',
            name: 'Mix',
            createdAt: DateTime.now(),
          ),
        );
    await database
        .into(database.playlistSongs)
        .insert(
          PlaylistSongsCompanion.insert(
            playlistId: 'p',
            songId: videoId,
            position: 0,
          ),
        );

    await repository.refreshFromDevice();

    final library = await repository.allSongs();
    expect(library.map((s) => s.title), ['Song']);
    expect(
      await database.select(database.songVibes).get(),
      isEmpty,
      reason: 'a removed video must not leave a dangling vibe assignment',
    );
    expect(
      await database.select(database.playlistSongs).get(),
      isEmpty,
      reason: 'a removed video must not linger in playlists',
    );
  });

  test('video ids are namespaced so they cannot collide with audio', () async {
    // MediaStore numbers audio and video independently, so id 1 can name
    // both; without the prefix the second would overwrite the first.
    final scanner = _FakeScanner(
      audio: [_audioSong('1', 'Song')],
      videos: [_videoSong('1', 'Clip')],
    );
    final repository = repositoryWith(scanner);

    await repository.refreshFromDevice(includeVideos: true);

    final library = await repository.allSongs();
    expect(library, hasLength(2));
    expect(
      library.map((s) => s.id),
      containsAll(['1', '${videoSongIdPrefix}1']),
    );
  });

  test('a video query with no platform handler yields no videos', () async {
    // Non-Android platforms have no handler registered; the scan must fall
    // back to audio-only rather than failing.
    final videos = await VideoQueryService().queryVideos();
    expect(videos, isEmpty);
  });
}
