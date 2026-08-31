import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/services/audio_visualizer_service.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../data/models/song.dart';
import '../../../data/repositories/game_score_repository.dart';
import '../../../shared/widgets/gradient_app_bar.dart';
import '../../../shared/widgets/song_artwork.dart';
import '../../playback/application/playback_controller.dart';
import '../../settings/application/settings_controller.dart';
import '../../visualizer/application/visualizer_source_controller.dart';
import '../application/beat_detector.dart';
import '../application/game_clock.dart';
import '../application/game_scoring.dart';
import '../application/simulated_beat_source.dart';
import '../application/tile_geometry.dart';
import 'rhythm_tile_painter.dart';

/// Rhythm mode: tap the tiles the music throws at you.
///
/// Three parts, top to bottom — artwork (which will later carry an ad), then
/// the title, scores and transport, then the board filling everything left.
/// The board goes last so it gets the tall end of the screen and so the
/// controls never move as tiles come and go. Everything about the tiles' look
/// comes from the visualizer settings, because this is meant to read as a
/// playable version of the visualizer rather than a separate game.
///
/// **What this is and is not.** The Android capture reports audio that has
/// already been rendered, so a tile can never land on the beat that created
/// it — the gap runs to about a second once capture, the wait for the beat's
/// sustain to finish, and the tile's own fall are added up. Fall time is
/// therefore snapped to a whole number of beat periods when one can be
/// estimated, so tiles land on a *later* beat and tapping along still lands
/// in time with the music. Judging happens purely on the game clock against
/// each tile's own arrival, never against audio position, so within the game
/// the timing is exact.
class RhythmGameScreen extends ConsumerStatefulWidget {
  const RhythmGameScreen({super.key});

  @override
  ConsumerState<RhythmGameScreen> createState() => _RhythmGameScreenState();
}

class _RhythmGameScreenState extends ConsumerState<RhythmGameScreen> {
  /// Lifted here so the board can write scores and the transport row can read
  /// them without either rebuilding the other.
  final ValueNotifier<RunScore> _run = ValueNotifier(const RunScore());

  /// Whether the tiles are coming from the stand-in pattern rather than the
  /// song. Written by the board — only it knows whether the real capture is
  /// actually producing beats, as opposed to merely being attached — and read
  /// by the banner.
  final ValueNotifier<bool> _simulated = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    // The player is looking at the screen and tapping, not touching the
    // system's idle timer.
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _run.dispose();
    _simulated.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final song = ref.watch(
      playbackControllerProvider.select((state) => state.currentSong),
    );

    return Scaffold(
      appBar: GradientAppBar(title: const Text('Rhythm mode')),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppGradients.surface(scheme)),
        child: SafeArea(
          child: song == null
              ? const Center(child: Text('Play something to start a run.'))
              : Column(
                  children: [
                    _ArtworkPanel(song: song),
                    _TransportAndScores(song: song, run: _run),
                    _SimulatedSourceBanner(simulated: _simulated),
                    Expanded(
                      child: _TileField(
                        song: song,
                        run: _run,
                        simulated: _simulated,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Part 1 — the artwork.
///
/// Fixed height on purpose: an ad is meant to sit in this box later, and a
/// panel that changes height would relayout the board underneath it.
class _ArtworkPanel extends StatelessWidget {
  const _ArtworkPanel({required this.song});

  static const _heightFraction = 0.24;

  final Song song;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * _heightFraction;
    final size = height - 24;

    return SizedBox(
      height: height,
      child: Center(
        child: SongArtwork(
          song: song,
          size: size < 0 ? 0 : size,
          borderRadius: 18,
          iconSize: 40,
        ),
      ),
    );
  }
}

/// Says plainly when the tiles are not following the song.
///
/// Without the opt-in Android capture there is no real audio to read, and the
/// stand-in pattern has nothing to do with the track. The game stays playable
/// in that case, but it must not imply it is hearing anything.
///
/// Driven by [simulated] — what the board actually ended up using — rather
/// than by whether a capture is attached. On some devices the capture attaches
/// and then reports silence, and a banner keyed off attachment alone would
/// claim the tiles were following a song they were not.
class _SimulatedSourceBanner extends ConsumerWidget {
  const _SimulatedSourceBanner({required this.simulated});

  final ValueNotifier<bool> simulated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<bool>(
      valueListenable: simulated,
      builder: (context, isSimulated, _) =>
          isSimulated ? _banner(context, ref) : const SizedBox.shrink(),
    );
  }

  Widget _banner(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final supported = ref.watch(audioVisualizerServiceProvider).isSupported;
    // Attached but producing nothing is a different situation from never
    // having been switched on, and only one of the two has a useful button.
    final attached = ref.watch(realVisualizerActiveProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: scheme.onTertiaryContainer,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(switch ((supported, attached)) {
                (false, _) =>
                  'Simulated beat — reading real audio is only available '
                      'on Android.',
                (true, true) =>
                  "Simulated beat — this device's audio capture isn't "
                      'reporting anything to follow.',
                (true, false) =>
                  'Simulated beat — these tiles follow a stand-in pattern, '
                      'not this song.',
              }, style: TextStyle(color: scheme.onTertiaryContainer)),
            ),
            if (supported && !attached) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _enableRealAudio(context, ref),
                child: const Text('Use real audio'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _enableRealAudio(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final enabled = await ref
        .read(settingsControllerProvider.notifier)
        .setRealVisualizerEnabled(true);
    if (!enabled) {
      // The controller already leaves the setting off when the microphone
      // permission is refused; say so rather than looking inert.
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Permission denied, so the beat stays simulated.'),
        ),
      );
    }
  }
}

/// Part 2 — the board.
///
/// Owns everything that moves at frame rate and never calls `setState`: the
/// painter repaints off a [Listenable], and the score goes out through a
/// [ValueNotifier]. A `setState` per frame here would rebuild the artwork and
/// the transport row sixty times a second for nothing.
class _TileField extends ConsumerStatefulWidget {
  const _TileField({
    required this.song,
    required this.run,
    required this.simulated,
  });

  final Song song;
  final ValueNotifier<RunScore> run;

  /// Set to true whenever the board is running on the stand-in pattern, so
  /// the banner above can say so.
  final ValueNotifier<bool> simulated;

  @override
  ConsumerState<_TileField> createState() => _TileFieldState();
}

class _TileFieldState extends ConsumerState<_TileField>
    with SingleTickerProviderStateMixin {
  static const _laneCount = 4;
  static const _hitLineFraction = 0.82;

  /// Keeps the board from becoming a wall on a dense track, and caps the
  /// per-frame painting cost.
  static const _maxTiles = 32;

  late final Ticker _ticker = createTicker(_onTick);
  final ValueNotifier<int> _repaint = ValueNotifier(0);
  final GameClock _clock = GameClock();
  final List<GameTile> _tiles = [];
  final Map<int, double> _flashes = {};
  final List<Duration> _recentOnsets = [];

  late BeatDetector _detector;
  late SimulatedBeatSource _simulated;
  late GameScoreRepository _scores;

  /// How long the board may sit empty before the stand-in pattern takes over.
  ///
  /// The capture can attach and then report nothing — a silent passage, an
  /// OEM that returns zeroes, a session that moved out from under it. Without
  /// this the game just shows an empty board and looks broken, which is
  /// exactly what it did.
  static const _silenceBeforeFallback = Duration(milliseconds: 2500);

  Duration _travel = TileGeometry.defaultTravel;
  Duration _simulatedCursor = Duration.zero;
  int _nextTileId = 0;
  String? _runSongId;
  bool _committed = false;

  /// Game-clock time of the last beat the *real* detector produced, used to
  /// decide when to fall back and when to hand control back.
  double? _lastRealBeatMs;

  @override
  void initState() {
    super.initState();
    _scores = ref.read(gameScoreRepositoryProvider);
    _startRun(widget.song);
    _ticker.start();

    // Real capture frames. `listenManual` rather than `watch` so a 20 Hz feed
    // never rebuilds a widget.
    ref.listenManual<List<double>?>(visualizerSourceControllerProvider, (
      _,
      bands,
    ) {
      if (bands == null) return;
      _onBands(bands);
    });

    ref.listenManual<Duration>(
      playbackControllerProvider.select((state) => state.position),
      (_, position) => _clock.sync(
        position,
        speed: ref.read(playbackControllerProvider).speed,
      ),
    );

    ref.listenManual<bool>(
      playbackControllerProvider.select((state) => state.isPlaying),
      (_, playing) => playing ? _clock.resume() : _clock.pause(),
      fireImmediately: true,
    );

    ref.listenManual<String?>(
      playbackControllerProvider.select((state) => state.currentSong?.id),
      (_, songId) {
        if (songId == null || songId == _runSongId) return;
        _commitRun();
        final song = ref.read(playbackControllerProvider).currentSong;
        if (song != null) _startRun(song);
      },
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    _commitRun();
    _repaint.dispose();
    super.dispose();
  }

  void _startRun(Song song) {
    _runSongId = song.id;
    _committed = false;
    _tiles.clear();
    _flashes.clear();
    _recentOnsets.clear();
    _travel = TileGeometry.defaultTravel;
    _lastRealBeatMs = null;
    _detector = BeatDetector(
      config: BeatDetectorConfig.from(ref.read(visualizerTuningProvider)),
    );
    _simulated = SimulatedBeatSource(seed: song.id.hashCode);
    _clock.reset();
    // Seeded from where the track actually is, not from zero: the clock
    // resyncs to the real position within a frame or two, and a cursor left
    // at zero would then be asked for every beat since the start of the song.
    _simulatedCursor = _clock.audioPosition;
    widget.run.value = const RunScore();
  }

  /// Stores the finished run. Guarded because both a track change and
  /// `dispose` can reach it, and a run must only be recorded once.
  void _commitRun() {
    if (_committed) return;
    _committed = true;
    final songId = _runSongId;
    final score = widget.run.value;
    if (songId == null || score.judged == 0) return;
    // Deliberately not awaited: this runs on the dispose path, where there is
    // nothing left to report a failure to.
    _scores.recordRun(songId, score: score.score, maxCombo: score.bestCombo);
  }

  void _onBands(List<double> bands) {
    final events = _detector.add(
      BandFrame(bands: bands, position: _clock.audioPosition),
    );
    if (events.isEmpty) return;
    _lastRealBeatMs = _clock.nowMs;
    // A capture that has started producing again takes the board back.
    widget.simulated.value = false;
    for (final event in events) {
      _spawn(event);
    }
  }

  /// Adds a tile for [event].
  ///
  /// [hitAtMs] is for beats that are still in the *future* — the stand-in
  /// pattern is generated a fall-time ahead, so each of its beats knows
  /// exactly when it should land and a window of them spreads out down the
  /// board. Real onsets have no such luxury: the capture only reports what has
  /// already played, so they take the default of "one fall from now", with the
  /// fall snapped to a whole number of beat periods so the tile still lands on
  /// a beat. See the class doc.
  void _spawn(BeatEvent event, {double? hitAtMs}) {
    _recentOnsets.add(event.position);
    if (_recentOnsets.length > 24) _recentOnsets.removeAt(0);

    _travel = TileGeometry.quantiseTravel(
      TileGeometry.defaultTravel,
      estimateBeatPeriod(_recentOnsets),
    );

    if (_tiles.length >= _maxTiles) return;
    final now = _clock.nowMs;
    _tiles.add(
      GameTile(
        id: _nextTileId++,
        lane: event.lane.clamp(0, _laneCount - 1),
        spawnMs: now,
        hitMs: hitAtMs ?? now + _travel.inMilliseconds,
        sustain: event.sustain,
        level: event.level,
        strength: event.strength,
      ),
    );
  }

  /// Whether the stand-in pattern should be driving the board right now.
  ///
  /// True when there is no capture at all, and also when there *is* one that
  /// has gone quiet for [_silenceBeforeFallback] — an attached capture that
  /// reports nothing used to leave the board permanently empty.
  bool get _needsSimulatedBeats {
    if (ref.read(visualizerSourceControllerProvider) == null) return true;
    final lastReal = _lastRealBeatMs;
    if (lastReal == null) return true;
    return _clock.nowMs - lastReal > _silenceBeforeFallback.inMilliseconds;
  }

  /// Lays down the stand-in pattern's beats for the stretch of song about to
  /// play.
  ///
  /// Generated a fall-time *ahead* of the playhead, so each tile can be given
  /// the exact moment its beat lands and a whole window of them arrives
  /// spread down the board rather than stacked on one instant.
  void _generateSimulatedBeats() {
    if (!_needsSimulatedBeats) return;
    widget.simulated.value = true;

    final position = _clock.audioPosition;
    final until = position + _travel;
    // A seek — or the clock's first resync away from zero — leaves the cursor
    // far behind or ahead. Neither is a stretch of song anyone is about to
    // hear, so skip to the playhead instead of generating minutes of beats.
    if (_simulatedCursor < position || _simulatedCursor > until) {
      _simulatedCursor = position;
    }
    if (until <= _simulatedCursor) return;

    for (final event in _simulated.eventsBetween(_simulatedCursor, until)) {
      final aheadMs = (event.position - position).inMilliseconds.toDouble();
      _spawn(event, hitAtMs: _clock.nowMs + (aheadMs < 0 ? 0 : aheadMs));
    }
    _simulatedCursor = until;
  }

  void _onTick(Duration elapsed) {
    _clock.tick(elapsed);

    if (_clock.isRunning) _generateSimulatedBeats();

    final now = _clock.nowMs;
    const config = ScoringConfig();
    var missed = 0;
    _tiles.removeWhere((tile) {
      final expired = TileGeometry.isExpired(
        nowMs: now,
        hitMs: tile.hitMs,
        goodWindow: config.goodWindow,
      );
      if (expired) missed++;
      return expired;
    });
    for (var i = 0; i < missed; i++) {
      widget.run.value = widget.run.value.applyMiss();
    }

    _flashes.removeWhere((_, at) => now - at > 240);
    _repaint.value++;
  }

  void _onTap(Offset localPosition, Size size) {
    if (size.width <= 0) return;
    final lane = (localPosition.dx / (size.width / _laneCount)).floor().clamp(
      0,
      _laneCount - 1,
    );
    final now = _clock.nowMs;
    _flashes[lane] = now;

    const config = ScoringConfig();
    GameTile? best;
    var bestError = double.infinity;
    for (final tile in _tiles) {
      if (tile.lane != lane) continue;
      final error = (tile.hitMs - now).abs();
      if (error < bestError) {
        bestError = error;
        best = tile;
      }
    }

    if (best == null ||
        bestError > config.goodWindow.inMilliseconds.toDouble()) {
      // A tap with nothing in reach. It costs the combo, which is what stops
      // mashing every lane from being the best strategy.
      widget.run.value = widget.run.value.applyStray();
      return;
    }

    final judgement = judgeHit(
      Duration(milliseconds: (now - best.hitMs).round()),
      config: config,
    );
    widget.run.value = widget.run.value.applyHit(judgement, best.sustain);
    _tiles.remove(best);
  }

  @override
  Widget build(BuildContext context) {
    final color = ref.watch(visualizerColorProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return RepaintBoundary(
          child: Listener(
            // onPointerDown, not a tap gesture: a tap waits for pointer-up and
            // for the gesture arena to settle, and this screen cannot spare
            // those milliseconds.
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) => _onTap(event.localPosition, size),
            child: CustomPaint(
              size: Size.infinite,
              painter: RhythmTilePainter(
                tiles: _tiles,
                nowMs: _clock.nowMs,
                travelMs: _travel.inMilliseconds.toDouble(),
                laneCount: _laneCount,
                color: color,
                hitLineFraction: _hitLineFraction,
                flashes: _flashes,
                repaint: _repaint,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Part 3 — transport plus the live score against the stored best.
class _TransportAndScores extends ConsumerWidget {
  const _TransportAndScores({required this.song, required this.run});

  final Song song;
  final ValueNotifier<RunScore> run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlaying = ref.watch(
      playbackControllerProvider.select((state) => state.isPlaying),
    );
    final best = ref.watch(gameScoreStreamProvider(song.id)).value;
    final controller = ref.read(playbackControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            song.title,
            style: theme.textTheme.titleMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          ValueListenableBuilder<RunScore>(
            valueListenable: run,
            builder: (context, score, _) => Text(
              'Score ${score.score}   ·   Best ${best?.highScore ?? 0}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.skip_previous),
                tooltip: 'Previous',
                onPressed: controller.previous,
              ),
              const SizedBox(width: 12),
              IconButton(
                iconSize: 48,
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                ),
                tooltip: isPlaying ? 'Pause' : 'Play',
                onPressed: controller.togglePlayPause,
              ),
              const SizedBox(width: 12),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.skip_next),
                tooltip: 'Next',
                onPressed: controller.next,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
