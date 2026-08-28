import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/features/game/application/tile_geometry.dart';
import 'package:zivybb/features/game/presentation/rhythm_game_screen.dart';
import 'package:zivybb/features/game/presentation/rhythm_tile_painter.dart';
import 'package:zivybb/features/playback/application/playback_controller.dart';
import 'package:zivybb/features/playback/presentation/now_playing_more_sheet.dart';
import 'package:zivybb/features/playback/presentation/now_playing_screen.dart';
import 'package:zivybb/features/visualizer/application/visualizer_source_controller.dart';

import 'support/fake_playback.dart';

/// Stands in for the native capture so a test can choose whether the game is
/// following real audio or the simulated fallback.
class FakeVisualizerSource extends VisualizerSourceController {
  FakeVisualizerSource(this.bands);

  final List<double>? bands;

  @override
  List<double>? build() => bands;
}

GameTile _tile({
  int lane = 0,
  double hitMs = 900,
  double level = 0.6,
  double strength = 0.8,
  Duration sustain = const Duration(milliseconds: 200),
}) => GameTile(
  id: 1,
  lane: lane,
  spawnMs: 0,
  hitMs: hitMs,
  sustain: sustain,
  level: level,
  strength: strength,
);

/// Drift schedules a zero-duration cleanup timer on cancellation, so every
/// widget test has to unmount and pump once or the test ends with a pending
/// timer.
Future<void> _teardown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  group('RhythmTilePainter', () {
    void paint(RhythmTilePainter painter, [Size size = const Size(360, 600)]) {
      final recorder = ui.PictureRecorder();
      painter.paint(Canvas(recorder), size);
      recorder.endRecording().dispose();
    }

    RhythmTilePainter painterWith(List<GameTile> tiles, {double nowMs = 450}) {
      return RhythmTilePainter(
        tiles: tiles,
        nowMs: nowMs,
        travelMs: 900,
        laneCount: 4,
        color: const Color(0xFF673AB7),
        hitLineFraction: 0.82,
      );
    }

    test('paints an empty board without throwing', () {
      expect(() => paint(painterWith(const [])), returnsNormally);
    });

    test('paints tiles in every lane', () {
      final tiles = [for (var lane = 0; lane < 4; lane++) _tile(lane: lane)];
      expect(() => paint(painterWith(tiles)), returnsNormally);
    });

    test('survives tiles above, below, and past the board', () {
      final tiles = [
        _tile(hitMs: -5000),
        _tile(hitMs: 50000),
        _tile(hitMs: 450),
      ];
      expect(() => paint(painterWith(tiles)), returnsNormally);
    });

    test('survives hostile tile values', () {
      final tiles = [
        _tile(level: double.nan, strength: double.infinity),
        _tile(level: -3, strength: -1),
        _tile(lane: 99),
        _tile(sustain: Duration.zero),
      ];
      expect(() => paint(painterWith(tiles)), returnsNormally);
    });

    test('survives a degenerate canvas', () {
      expect(() => paint(painterWith([_tile()]), Size.zero), returnsNormally);
      expect(
        () => paint(painterWith([_tile()]), const Size(1, 1)),
        returnsNormally,
      );
    });

    test('paints a full board without throwing', () {
      final tiles = [
        for (var i = 0; i < 200; i++)
          _tile(lane: i % 4, hitMs: 100.0 * i, level: (i % 10) / 10),
      ];
      expect(() => paint(painterWith(tiles)), returnsNormally);
    });
  });

  group('RhythmGameScreen', () {
    Widget wrap({
      required AppDatabase database,
      required PlaybackState playback,
      List<double>? bands,
    }) {
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          playbackControllerProvider.overrideWith(
            () => FakePlaybackController(initial: playback),
          ),
          visualizerSourceControllerProvider.overrideWith(
            () => FakeVisualizerSource(bands),
          ),
        ],
        child: const MaterialApp(home: RhythmGameScreen()),
      );
    }

    testWidgets('says so when nothing is playing', (tester) async {
      final database = AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        wrap(database: database, playback: const PlaybackState()),
      );
      await tester.pump();

      expect(find.text('Play something to start a run.'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('shows the three parts while a song is playing', (
      tester,
    ) async {
      final database = AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);
      final song = fakeSong(title: 'Blue Monday');

      await tester.pumpWidget(
        wrap(
          database: database,
          playback: playingState(song),
          bands: List<double>.filled(32, 0.4),
        ),
      );
      await tester.pump();

      // Part 3 carries the title and the scores; part 2 is the painted board.
      expect(find.text('Blue Monday'), findsOneWidget);
      expect(find.textContaining('Score 0'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous), findsOneWidget);

      await _teardown(tester);
    });

    testWidgets('warns that the beat is simulated when there is no feed', (
      tester,
    ) async {
      final database = AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        wrap(
          database: database,
          playback: playingState(fakeSong()),
          bands: null,
        ),
      );
      await tester.pump();

      expect(find.textContaining('Simulated beat'), findsOneWidget);
      await _teardown(tester);
    });

    testWidgets('stays quiet when the real feed is live', (tester) async {
      final database = AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        wrap(
          database: database,
          playback: playingState(fakeSong()),
          bands: List<double>.filled(32, 0.4),
        ),
      );
      await tester.pump();

      expect(find.textContaining('Simulated beat'), findsNothing);
      await _teardown(tester);
    });
  });

  group('the equalizer moved off the Now Playing app bar', () {
    testWidgets('the app bar offers rhythm mode, not the equalizer', (
      tester,
    ) async {
      final database = AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            playbackControllerProvider.overrideWith(
              () => FakePlaybackController(),
            ),
          ],
          child: const MaterialApp(home: NowPlayingScreen()),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.equalizer), findsNothing);
      expect(find.byIcon(Icons.videogame_asset_outlined), findsOneWidget);

      await _teardown(tester);
    });

    testWidgets('the more sheet lists Equalizer directly under Edit tags', (
      tester,
    ) async {
      final database = AppDatabase.connect(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
          child: const MaterialApp(
            home: Scaffold(
              body: NowPlayingMoreSheet(canRemoveFromPlaylist: false),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Equalizer'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Equalizer')).dy,
        greaterThan(tester.getTopLeft(find.text('Edit tags')).dy),
        reason: 'the user asked for it directly under Edit tags',
      );
      expect(
        tester.getTopLeft(find.text('Equalizer')).dy,
        lessThan(tester.getTopLeft(find.text('Set as ringtone')).dy),
      );

      await _teardown(tester);
    });
  });
}
