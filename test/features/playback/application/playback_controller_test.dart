import 'dart:async';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/core/services/audio_engine.dart';
import 'package:zivybb/data/models/song.dart';
import 'package:zivybb/features/playback/application/playback_controller.dart';

void main() {
  late FakeAudioEngine engine;
  late PlaybackController controller;

  setUp(() {
    engine = FakeAudioEngine();
    controller = PlaybackController(engine: engine, random: Random(1));
  });

  tearDown(() => controller.dispose());

  test('plays the song at the requested index', () async {
    await controller.playQueue(_library, startIndex: 1);

    expect(controller.currentSong?.id, 'b');
    expect(controller.isPlaying, isTrue);
    expect(engine.isPlaying, isTrue);
  });

  test('drops missing files from the queue', () async {
    await controller.playQueue(_library);

    expect(controller.queue.map((song) => song.id), ['a', 'b', 'c']);
  });

  test(
    'starts at the next playable song when asked for a missing one',
    () async {
      // Index 2 is the missing track.
      await controller.playQueue(_library, startIndex: 2);

      expect(controller.currentSong?.id, 'c');
    },
  );

  test('next walks the queue in order', () async {
    await controller.playQueue(_library);
    await controller.next();

    expect(controller.currentSong?.id, 'b');
  });

  test('next at the end of the queue stops playback', () async {
    await controller.playQueue(_library, startIndex: 3);
    await controller.next();

    expect(controller.currentSong?.id, 'c');
    expect(controller.isPlaying, isFalse);
  });

  test('finishing a track advances to the next one', () async {
    await controller.playQueue(_library);

    engine.completeTrack();
    await _settle();

    expect(controller.currentSong?.id, 'b');
  });

  test('previous restarts the track once it is underway', () async {
    await controller.playQueue(_library, startIndex: 1);

    engine.emitPosition(const Duration(seconds: 10));
    await _settle();
    await controller.previous();

    expect(controller.currentSong?.id, 'b');
    expect(engine.position, Duration.zero);
  });

  test('previous steps back when the track just started', () async {
    await controller.playQueue(_library, startIndex: 1);

    engine.emitPosition(const Duration(seconds: 1));
    await _settle();
    await controller.previous();

    expect(controller.currentSong?.id, 'a');
  });

  test('shuffle keeps the current song playing', () async {
    await controller.playQueue(_library, startIndex: 1);
    await controller.toggleShuffle();

    expect(controller.isShuffleEnabled, isTrue);
    expect(controller.currentSong?.id, 'b');
  });

  test('progress reflects position against duration', () async {
    await controller.playQueue(_library);

    engine.emitPosition(const Duration(seconds: 30));
    await _settle();

    expect(controller.progress, closeTo(0.5, 0.001));
  });
}

/// Lets broadcast stream events reach the controller before asserting.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

const _library = <Song>[
  Song(
    id: 'a',
    filePath: '/music/a.mp3',
    title: 'A',
    artist: 'Artist',
    album: 'Album',
    duration: Duration(minutes: 1),
  ),
  Song(
    id: 'b',
    filePath: '/music/b.mp3',
    title: 'B',
    artist: 'Artist',
    album: 'Album',
    duration: Duration(minutes: 1),
  ),
  Song(
    id: 'missing',
    filePath: '/music/missing.mp3',
    title: 'Missing',
    artist: 'Artist',
    album: 'Album',
    duration: Duration(minutes: 1),
    isMissing: true,
  ),
  Song(
    id: 'c',
    filePath: '/music/c.mp3',
    title: 'C',
    artist: 'Artist',
    album: 'Album',
    duration: Duration(minutes: 1),
  ),
];

class FakeAudioEngine implements AudioEngine {
  final _positions = StreamController<Duration>.broadcast();
  final _completions = StreamController<void>.broadcast();

  Duration _position = Duration.zero;
  Song? loadedSong;
  bool isPlaying = false;

  @override
  Duration get position => _position;

  @override
  Stream<Duration> get positionStream => _positions.stream;

  @override
  Stream<void> get trackCompletions => _completions.stream;

  @override
  Future<void> load(Song song) async {
    loadedSong = song;
    _position = Duration.zero;
  }

  @override
  Future<void> play() async => isPlaying = true;

  @override
  Future<void> pause() async => isPlaying = false;

  @override
  Future<void> seek(Duration position) async => emitPosition(position);

  @override
  Future<void> dispose() async {
    await _positions.close();
    await _completions.close();
  }

  void emitPosition(Duration position) {
    _position = position;
    _positions.add(position);
  }

  void completeTrack() => _completions.add(null);
}
