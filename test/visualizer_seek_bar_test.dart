import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/models/app_settings.dart';
import 'package:zivybb/data/repositories/settings_repository.dart';
import 'package:zivybb/features/playback/application/playback_controller.dart';
import 'package:zivybb/features/playback/presentation/now_playing_screen.dart';
import 'package:zivybb/features/visualizer/presentation/visualizer_seek_bar.dart';

import 'support/fake_playback.dart';

/// The visualizer animates continuously, so `pumpAndSettle` never returns on
/// Now Playing — pump a fixed handful of frames instead.
Future<void> _pumpFrames(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<void> _teardown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  group('VisualizerStyle.seekBarShape', () {
    test('the wide styles become a horizontal track', () {
      for (final style in [
        VisualizerStyle.bars,
        VisualizerStyle.mirror,
        VisualizerStyle.line,
        VisualizerStyle.ribbon,
      ]) {
        expect(style.seekBarShape, VisualizerSeekBarShape.horizontal);
        expect(style.supportsSeekBar, isTrue);
      }
    });

    test('the circular styles become a ring', () {
      for (final style in [VisualizerStyle.radial, VisualizerStyle.particles]) {
        expect(style.seekBarShape, VisualizerSeekBarShape.circular);
        expect(style.supportsSeekBar, isTrue);
      }
    });

    test('bloom cannot be a seek bar', () {
      expect(
        VisualizerStyle.bloom.seekBarShape,
        VisualizerSeekBarShape.unsupported,
      );
      expect(VisualizerStyle.bloom.supportsSeekBar, isFalse);
    });
  });

  group('AppSettings seek-bar placement', () {
    const onSeekBar = AppSettings(
      visualizerPlacement: VisualizerPlacement.seekBar,
    );

    test('a horizontal style takes the seek bar but not the artwork', () {
      const settings = AppSettings(
        visualizerPlacement: VisualizerPlacement.seekBar,
        visualizerStyle: VisualizerStyle.bars,
      );
      expect(settings.visualizerIsSeekBar, isTrue);
      expect(settings.visualizerIsCircularSeekBar, isFalse);
    });

    test('a circular style takes the artwork slot as a ring', () {
      const settings = AppSettings(
        visualizerPlacement: VisualizerPlacement.seekBar,
        visualizerStyle: VisualizerStyle.radial,
      );
      expect(settings.visualizerIsCircularSeekBar, isTrue);
      expect(
        settings.visualizerFillsArtworkSlot(songHasArtwork: true),
        isFalse,
        reason: 'the ring shows the artwork inside it rather than hiding it',
      );
    });

    test('bloom on the seek bar falls back rather than losing the bar', () {
      const settings = AppSettings(
        visualizerPlacement: VisualizerPlacement.seekBar,
        visualizerStyle: VisualizerStyle.bloom,
      );
      expect(
        settings.effectiveVisualizerPlacement,
        VisualizerPlacement.belowControls,
      );
      expect(settings.visualizerIsSeekBar, isFalse);
    });

    test('the default style keeps the stored choice intact', () {
      expect(
        onSeekBar.effectiveVisualizerPlacement,
        VisualizerPlacement.seekBar,
      );
    });
  });

  group('progressFraction', () {
    test('maps position onto the track', () {
      expect(
        progressFraction(
          const Duration(seconds: 30),
          const Duration(minutes: 1),
        ),
        closeTo(0.5, 1e-9),
      );
    });

    test('an unknown duration reads as the start, not as NaN', () {
      expect(progressFraction(const Duration(seconds: 5), Duration.zero), 0.0);
    });

    test('never leaves the track', () {
      expect(
        progressFraction(
          const Duration(minutes: 5),
          const Duration(minutes: 1),
        ),
        1.0,
      );
    });
  });

  group('Now Playing with the visualizer as the seek bar', () {
    late AppDatabase database;

    setUp(() => database = AppDatabase.connect(NativeDatabase.memory()));
    tearDown(() => database.close());

    Future<void> pumpWith(
      WidgetTester tester, {
      required VisualizerStyle style,
    }) async {
      final settings = SettingsRepository(database: database);
      await settings.setVisualizerStyle(style);
      await settings.setVisualizerPlacement(VisualizerPlacement.seekBar);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            playbackControllerProvider.overrideWith(
              () => FakePlaybackController(
                initial: PlaybackState(
                  queue: [fakeSong()],
                  currentIndex: 0,
                  isPlaying: true,
                  position: const Duration(seconds: 45),
                  duration: const Duration(minutes: 3),
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: NowPlayingScreen()),
        ),
      );
      await _pumpFrames(tester);
    }

    testWidgets('a horizontal style replaces the slider with the wave', (
      tester,
    ) async {
      await pumpWith(tester, style: VisualizerStyle.bars);

      expect(find.byType(VisualizerTrackSeekBar), findsOneWidget);
      expect(
        find.byType(Slider),
        findsNothing,
        reason: 'the wave is the bar now, rather than sitting behind one',
      );

      await _teardown(tester);
    });

    testWidgets('a circular style becomes a ring and drops the linear bar', (
      tester,
    ) async {
      await pumpWith(tester, style: VisualizerStyle.radial);

      expect(find.byType(VisualizerRingSeekBar), findsOneWidget);
      expect(find.byType(VisualizerTrackSeekBar), findsNothing);
      expect(find.byType(Slider), findsNothing);

      await _teardown(tester);
    });

    testWidgets('bloom keeps an ordinary slider', (tester) async {
      await pumpWith(tester, style: VisualizerStyle.bloom);

      expect(find.byType(Slider), findsOneWidget);
      expect(find.byType(VisualizerTrackSeekBar), findsNothing);
      expect(find.byType(VisualizerRingSeekBar), findsNothing);

      await _teardown(tester);
    });

    testWidgets('dragging across the wave seeks', (tester) async {
      await pumpWith(tester, style: VisualizerStyle.bars);

      final bar = find.byType(VisualizerTrackSeekBar);
      final box = tester.getRect(bar);
      // Press near the right-hand end, which is late in the track.
      await tester.tapAt(Offset(box.right - 8, box.center.dy));
      await _pumpFrames(tester);

      // FakePlaybackController records nothing, so what is asserted here is
      // that the gesture is wired and doesn't throw; the seek target itself
      // is covered by progressFraction above.
      expect(tester.takeException(), isNull);

      await _teardown(tester);
    });
  });
}
