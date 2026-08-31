import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/repositories/settings_repository.dart';
import 'package:zivybb/features/playback/application/playback_controller.dart';
import 'package:zivybb/features/playback/presentation/now_playing_gestures.dart';
import 'package:zivybb/features/playback/presentation/now_playing_more_sheet.dart';
import 'package:zivybb/features/playback/presentation/now_playing_screen.dart';

import 'support/fake_playback.dart';

/// Records the transport calls a gesture makes, which is all a swipe test
/// can observe — the audio engine itself is out of reach here.
class _RecordingPlaybackController extends FakePlaybackController {
  _RecordingPlaybackController({required super.initial});

  final calls = <String>[];

  @override
  Future<void> next() async => calls.add('next');

  @override
  Future<void> previous() async => calls.add('previous');
}

/// Pumps a fixed handful of frames rather than settling.
///
/// Now Playing draws the visualizer, which animates for as long as it is on
/// screen, so `pumpAndSettle` never returns here — it waits for a tree that
/// is never done animating.
Future<void> _pumpFrames(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Drift schedules a zero-duration cleanup timer on cancellation, so every
/// widget test has to unmount and pump once or the test ends with a pending
/// timer.
Future<void> _teardown(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 1));
}

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase.connect(NativeDatabase.memory()));
  tearDown(() => database.close());

  Future<void> pumpNowPlaying(
    WidgetTester tester, {
    required bool compact,
    PlaybackController? controller,
  }) async {
    if (compact) {
      await SettingsRepository(database: database).setCompactNowPlaying(true);
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          playbackControllerProvider.overrideWith(
            () =>
                controller ??
                FakePlaybackController(initial: playingState(fakeSong())),
          ),
        ],
        child: const MaterialApp(home: NowPlayingScreen()),
      ),
    );
    await _pumpFrames(tester);
  }

  group('compact Now Playing', () {
    testWidgets('the full layout shows the artist line and every control', (
      tester,
    ) async {
      await pumpNowPlaying(tester, compact: false);

      expect(find.text('Artist — Album'), findsOneWidget);
      expect(find.byIcon(Icons.shuffle), findsOneWidget);
      expect(find.byIcon(Icons.repeat), findsOneWidget);
      expect(find.byIcon(Icons.playlist_add), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);

      await _teardown(tester);
    });

    testWidgets('the compact layout keeps only the title and the three '
        'transport buttons', (tester) async {
      await pumpNowPlaying(tester, compact: true);

      expect(find.text('Test Song'), findsOneWidget);
      expect(
        find.text('Artist — Album'),
        findsNothing,
        reason: 'the compact layout drops the album line',
      );
      expect(find.byIcon(Icons.shuffle), findsNothing);
      expect(find.byIcon(Icons.repeat), findsNothing);
      expect(find.byIcon(Icons.playlist_add), findsNothing);
      expect(find.byIcon(Icons.favorite_border), findsNothing);

      // What it does keep.
      expect(find.byIcon(Icons.skip_previous), findsOneWidget);
      expect(find.byIcon(Icons.skip_next), findsOneWidget);
      expect(find.byIcon(Icons.mood), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);

      await _teardown(tester);
    });

    testWidgets('the app-bar toggle switches layouts and sticks', (
      tester,
    ) async {
      await pumpNowPlaying(tester, compact: false);
      expect(find.text('Artist — Album'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.unfold_less));
      await _pumpFrames(tester);

      expect(find.text('Artist — Album'), findsNothing);
      expect(
        (await SettingsRepository(
          database: database,
        ).currentSettings()).compactNowPlaying,
        isTrue,
        reason: 'the layout choice is remembered, not just rendered',
      );

      await _teardown(tester);
    });

    testWidgets('the compact more sheet carries what the row dropped', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            playbackControllerProvider.overrideWith(
              () => FakePlaybackController(initial: playingState(fakeSong())),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NowPlayingMoreSheet(
                canRemoveFromPlaylist: false,
                showTransportExtras: true,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Shuffle'), findsOneWidget);
      expect(find.text('Repeat'), findsOneWidget);
      expect(find.text('Save to playlist'), findsOneWidget);
      expect(find.text('Like'), findsOneWidget);

      await _teardown(tester);
    });

    testWidgets('the full layout keeps those out of the more sheet', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            playbackControllerProvider.overrideWith(
              () => FakePlaybackController(initial: playingState(fakeSong())),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: NowPlayingMoreSheet(canRemoveFromPlaylist: false),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text('Shuffle'),
        findsNothing,
        reason: 'the button is on screen already; listing it twice is noise',
      );

      await _teardown(tester);
    });
  });

  group('Now Playing swipe gestures', () {
    testWidgets('swiping left plays the next track', (tester) async {
      final controller = _RecordingPlaybackController(
        initial: playingState(fakeSong()),
      );
      await pumpNowPlaying(tester, compact: false, controller: controller);

      await tester.drag(
        find.byType(NowPlayingGestureArea),
        const Offset(-180, 0),
      );
      await _pumpFrames(tester);

      expect(controller.calls, ['next']);

      await _teardown(tester);
    });

    testWidgets('swiping right plays the previous track', (tester) async {
      final controller = _RecordingPlaybackController(
        initial: playingState(fakeSong()),
      );
      await pumpNowPlaying(tester, compact: false, controller: controller);

      await tester.drag(
        find.byType(NowPlayingGestureArea),
        const Offset(180, 0),
      );
      await _pumpFrames(tester);

      expect(controller.calls, ['previous']);

      await _teardown(tester);
    });

    testWidgets('a nudge too short to be a swipe changes nothing', (
      tester,
    ) async {
      final controller = _RecordingPlaybackController(
        initial: playingState(fakeSong()),
      );
      await pumpNowPlaying(tester, compact: false, controller: controller);

      await tester.drag(
        find.byType(NowPlayingGestureArea),
        const Offset(-30, 0),
      );
      await _pumpFrames(tester);

      expect(
        controller.calls,
        isEmpty,
        reason: 'a slip of the thumb must not skip the track',
      );

      await _teardown(tester);
    });

    testWidgets('a vertical swipe leaves the track alone', (tester) async {
      final controller = _RecordingPlaybackController(
        initial: playingState(fakeSong()),
      );
      await pumpNowPlaying(tester, compact: false, controller: controller);

      // No volume handler is registered in tests, so this reaches the volume
      // path and quietly does nothing — what matters is that it is not read
      // as a track change.
      await tester.drag(
        find.byType(NowPlayingGestureArea),
        const Offset(0, -180),
      );
      await _pumpFrames(tester);

      expect(controller.calls, isEmpty);

      await _teardown(tester);
    });
  });
}
