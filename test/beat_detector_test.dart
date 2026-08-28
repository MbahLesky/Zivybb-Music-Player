import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/data/models/app_settings.dart';
import 'package:zivybb/features/game/application/beat_detector.dart';
import 'package:zivybb/features/game/application/simulated_beat_source.dart';
import 'package:zivybb/features/game/application/tile_geometry.dart';

/// A frame of 32 bands, all at [level] unless [lane] overrides a range.
List<double> _bands({double level = 0.05, int? lane, double laneLevel = 0.9}) {
  const edges = BeatDetectorConfig.defaultLaneEdges;
  return List<double>.generate(32, (i) {
    if (lane == null) return level;
    return i >= edges[lane] && i < edges[lane + 1] ? laneLevel : level;
  });
}

/// Feeds frames at [stepMs] apart and returns everything detected.
List<BeatEvent> _run(
  BeatDetector detector,
  List<List<double>> frames, {
  int stepMs = 50,
  int startMs = 0,
}) {
  final events = <BeatEvent>[];
  for (var i = 0; i < frames.length; i++) {
    events.addAll(
      detector.add(
        BandFrame(
          bands: frames[i],
          position: Duration(milliseconds: startMs + i * stepMs),
        ),
      ),
    );
  }
  return events;
}

void main() {
  group('BeatDetector', () {
    test('silence produces no onsets', () {
      final events = _run(
        BeatDetector(),
        List.generate(60, (_) => _bands(level: 0.0)),
      );
      expect(events, isEmpty);
    });

    test('a loud but steady signal produces no onsets', () {
      // The defining property of flux-based detection, and the test that
      // stops someone "fixing" this into a level detector: a sustained pad is
      // loud but has no beat, so it must yield nothing.
      final events = _run(
        BeatDetector(),
        List.generate(60, (_) => _bands(level: 0.85)),
      );
      expect(events, isEmpty);
    });

    test('a bass transient fires lane 0 and nothing else', () {
      final frames = [
        ...List.generate(20, (_) => _bands(level: 0.05)),
        _bands(level: 0.05, lane: 0),
        ...List.generate(12, (_) => _bands(level: 0.05)),
      ];
      final events = _run(BeatDetector(), frames);

      expect(events, hasLength(1));
      expect(events.single.lane, 0);
    });

    test('the onset keeps the position it started on, not where it ended', () {
      // The wait for the sustain to close must not shift the beat.
      final frames = [
        ...List.generate(20, (_) => _bands(level: 0.05)),
        _bands(level: 0.05, lane: 1),
        ...List.generate(12, (_) => _bands(level: 0.05)),
      ];
      final events = _run(BeatDetector(), frames);

      expect(events.single.position, const Duration(milliseconds: 1000));
    });

    test('a second transient inside the refractory window is dropped', () {
      final quiet = _bands(level: 0.05);
      final frames = [
        ...List.generate(20, (_) => quiet),
        _bands(level: 0.05, lane: 0),
        quiet,
        _bands(level: 0.05, lane: 0), // 100ms later, inside the 150ms window
        ...List.generate(12, (_) => quiet),
      ];
      expect(_run(BeatDetector(), frames), hasLength(1));
    });

    test('a transient past the refractory window fires again', () {
      final quiet = _bands(level: 0.05);
      final frames = [
        ...List.generate(20, (_) => quiet),
        _bands(level: 0.05, lane: 0),
        ...List.generate(8, (_) => quiet), // 400ms gap
        _bands(level: 0.05, lane: 0),
        ...List.generate(12, (_) => quiet),
      ];
      expect(_run(BeatDetector(), frames), hasLength(2));
    });

    test('a broadband hit never lights every lane at once', () {
      final frames = [
        ...List.generate(20, (_) => _bands(level: 0.02)),
        _bands(level: 0.95),
        ...List.generate(12, (_) => _bands(level: 0.02)),
      ];
      final events = _run(BeatDetector(), frames);

      expect(events.length, lessThanOrEqualTo(2));
    });

    test('a held note gives a longer tile than a stab', () {
      List<BeatEvent> withHold(int holdFrames) {
        final quiet = _bands(level: 0.05);
        return _run(BeatDetector(), [
          ...List.generate(20, (_) => quiet),
          ...List.generate(holdFrames, (_) => _bands(level: 0.05, lane: 2)),
          ...List.generate(14, (_) => quiet),
        ]);
      }

      final stab = withHold(1).single.sustain;
      final held = withHold(6).single.sustain;
      expect(held, greaterThan(stab));
    });

    test('sustain is clamped to the configured range', () {
      final quiet = _bands(level: 0.05);
      final events = _run(BeatDetector(), [
        ...List.generate(20, (_) => quiet),
        ...List.generate(60, (_) => _bands(level: 0.05, lane: 2)),
        ...List.generate(14, (_) => quiet),
      ]);

      const config = BeatDetectorConfig();
      expect(events.single.sustain, lessThanOrEqualTo(config.maxSustain));
      expect(events.single.sustain, greaterThanOrEqualTo(config.minSustain));
    });

    test('seeking backwards resets instead of spraying phantom onsets', () {
      final detector = BeatDetector();
      _run(detector, List.generate(30, (_) => _bands(level: 0.4)));

      // A seek back to the start of the track.
      final events = detector.add(
        BandFrame(bands: _bands(level: 0.9), position: Duration.zero),
      );
      expect(events, isEmpty);
    });

    test('a forward jump larger than the resync window also resets', () {
      // What a crossfade handing over to the other audio session looks like.
      final detector = BeatDetector();
      _run(detector, List.generate(30, (_) => _bands(level: 0.4)));

      final events = detector.add(
        BandFrame(
          bands: _bands(level: 0.95),
          position: const Duration(seconds: 30),
        ),
      );
      expect(events, isEmpty);
    });

    test('hostile frames neither throw nor emit', () {
      final detector = BeatDetector();
      final hostile = [
        <double>[],
        [double.nan, double.infinity, -1.0, 4.0],
        List<double>.filled(12, 0.5),
        List<double>.filled(64, double.negativeInfinity),
      ];
      for (var i = 0; i < hostile.length; i++) {
        expect(
          () => detector.add(
            BandFrame(
              bands: hostile[i],
              position: Duration(milliseconds: i * 50),
            ),
          ),
          returnsNormally,
        );
      }
    });

    test('the same frames twice give the same events', () {
      final frames = [
        ...List.generate(20, (_) => _bands(level: 0.05)),
        _bands(level: 0.05, lane: 3),
        ...List.generate(12, (_) => _bands(level: 0.05)),
      ];
      final first = _run(BeatDetector(), frames);
      final second = _run(BeatDetector(), frames);

      expect(first.length, second.length);
      expect(first.single.position, second.single.position);
      expect(first.single.lane, second.single.lane);
    });

    test('every emitted level and strength stays inside 0..1', () {
      final frames = [
        ...List.generate(20, (_) => _bands(level: 0.02)),
        _bands(level: 0.02, lane: 0, laneLevel: 1.0),
        ...List.generate(12, (_) => _bands(level: 0.02)),
      ];
      for (final event in _run(BeatDetector(), frames)) {
        expect(event.level, inInclusiveRange(0.0, 1.0));
        expect(event.strength, inInclusiveRange(0.0, 1.0));
      }
    });
  });

  group('BeatDetectorConfig.from', () {
    test('more sensitivity lowers the bar an onset must clear', () {
      final quiet = BeatDetectorConfig.from(
        const VisualizerTuning(sensitivity: 0.5),
      );
      final keen = BeatDetectorConfig.from(
        const VisualizerTuning(sensitivity: 2.5),
      );
      expect(keen.thresholdMultiplier, lessThan(quiet.thresholdMultiplier));
    });

    test('more responsiveness shortens the refractory and the memory', () {
      final slow = BeatDetectorConfig.from(
        const VisualizerTuning(responsiveness: 0.0),
      );
      final fast = BeatDetectorConfig.from(
        const VisualizerTuning(responsiveness: 1.0),
      );
      expect(fast.laneRefractory, lessThan(slow.laneRefractory));
      expect(fast.fluxWindow, lessThan(slow.fluxWindow));
    });

    test('every tuning preset yields a usable config', () {
      for (final preset in VisualizerResponsePreset.values) {
        final config = BeatDetectorConfig.from(preset.tuning);
        expect(config.thresholdMultiplier, greaterThan(0));
        expect(config.fluxWindow, greaterThan(0));
        expect(config.laneRefractory, greaterThan(Duration.zero));
        expect(config.laneCount, 4);
      }
    });
  });

  group('SimulatedBeatSource', () {
    test('is deterministic for a seed', () {
      List<int> lanesFor(int seed) => SimulatedBeatSource(seed: seed)
          .eventsBetween(Duration.zero, const Duration(seconds: 10))
          .map((event) => event.lane)
          .toList();

      expect(lanesFor(42), lanesFor(42));
    });

    test('different tracks get different patterns', () {
      List<int> lanesFor(int seed) => SimulatedBeatSource(seed: seed)
          .eventsBetween(Duration.zero, const Duration(seconds: 20))
          .map((event) => event.lane)
          .toList();

      expect(lanesFor(1), isNot(equals(lanesFor(9999))));
    });

    test('produces a playable but not relentless number of beats', () {
      final events = SimulatedBeatSource(
        seed: 7,
      ).eventsBetween(Duration.zero, const Duration(seconds: 10));

      // 10s at 120bpm is 20 grid slots, a quarter of which are left empty.
      expect(events.length, inInclusiveRange(10, 20));
    });

    test('adjacent windows never repeat or drop a beat', () {
      final all = SimulatedBeatSource(
        seed: 3,
      ).eventsBetween(Duration.zero, const Duration(seconds: 10));
      final first = SimulatedBeatSource(
        seed: 3,
      ).eventsBetween(Duration.zero, const Duration(seconds: 4));
      final second = SimulatedBeatSource(
        seed: 3,
      ).eventsBetween(const Duration(seconds: 4), const Duration(seconds: 10));

      expect(first.length + second.length, all.length);
      expect([
        ...first.map((e) => e.position),
        ...second.map((e) => e.position),
      ], all.map((e) => e.position).toList());
    });

    test('every generated beat is in range', () {
      final events = SimulatedBeatSource(
        seed: 11,
      ).eventsBetween(Duration.zero, const Duration(seconds: 30));

      for (final event in events) {
        expect(event.lane, inInclusiveRange(0, 3));
        expect(event.level, inInclusiveRange(0.0, 1.0));
        expect(event.strength, inInclusiveRange(0.0, 1.0));
        expect(event.sustain, greaterThan(Duration.zero));
      }
    });
  });

  group('estimateBeatPeriod', () {
    List<Duration> pulses(int count, int periodMs) => [
      for (var i = 0; i < count; i++) Duration(milliseconds: i * periodMs),
    ];

    test('finds the period of a steady pulse train', () {
      final period = estimateBeatPeriod(pulses(12, 500));
      expect(period, isNotNull);
      expect(
        (period! - const Duration(milliseconds: 500)).inMilliseconds.abs(),
        lessThanOrEqualTo(25),
      );
    });

    test('returns null when there is too little to go on', () {
      expect(estimateBeatPeriod(pulses(3, 500)), isNull);
    });

    test('returns null when the gaps disagree', () {
      // Better no period than a wrong one — a wrong period puts every tile
      // confidently off the beat.
      final scattered = [
        Duration.zero,
        const Duration(milliseconds: 260),
        const Duration(milliseconds: 900),
        const Duration(milliseconds: 1010),
        const Duration(milliseconds: 1800),
        const Duration(milliseconds: 1860),
      ];
      expect(estimateBeatPeriod(scattered), isNull);
    });

    test('ignores gaps outside a plausible tempo range', () {
      final tooSlow = [
        for (var i = 0; i < 12; i++) Duration(milliseconds: i * 4000),
      ];
      expect(estimateBeatPeriod(tooSlow), isNull);
    });
  });

  group('TileGeometry', () {
    test('a tile sits exactly on the hit line at its hit time', () {
      final y = TileGeometry.headY(
        nowMs: 900,
        hitMs: 900,
        travelMs: 900,
        hitLineY: 600,
      );
      expect(y, closeTo(600, 0.001));
    });

    test('a tile starts at the top of the board', () {
      final y = TileGeometry.headY(
        nowMs: 0,
        hitMs: 900,
        travelMs: 900,
        hitLineY: 600,
      );
      expect(y, closeTo(0, 0.001));
    });

    test('length follows the sustain but never goes below the minimum', () {
      final long = TileGeometry.lengthPx(
        sustain: const Duration(milliseconds: 400),
        travelMs: 900,
        hitLineY: 600,
      );
      final stab = TileGeometry.lengthPx(
        sustain: const Duration(milliseconds: 20),
        travelMs: 900,
        hitLineY: 600,
      );
      expect(long, greaterThan(stab));
      expect(stab, TileGeometry.minimumLengthPx);
    });

    test('expiry flips just after the good window closes', () {
      const window = Duration(milliseconds: 250);
      expect(
        TileGeometry.isExpired(nowMs: 1240, hitMs: 1000, goodWindow: window),
        isFalse,
      );
      expect(
        TileGeometry.isExpired(nowMs: 1260, hitMs: 1000, goodWindow: window),
        isTrue,
      );
    });

    test('quantising snaps the fall to a whole number of beats', () {
      final travel = TileGeometry.quantiseTravel(
        const Duration(milliseconds: 900),
        const Duration(milliseconds: 500),
      );
      expect(travel, const Duration(milliseconds: 1000));
    });

    test('quantising keeps the preferred fall when no period is known', () {
      expect(
        TileGeometry.quantiseTravel(const Duration(milliseconds: 900), null),
        const Duration(milliseconds: 900),
      );
    });

    test('quantising refuses a snap outside the playable range', () {
      // A very slow "beat" would otherwise give a fall so long the board sits
      // empty, or so short the tiles are untappable.
      expect(
        TileGeometry.quantiseTravel(
          const Duration(milliseconds: 900),
          const Duration(milliseconds: 2000),
        ),
        const Duration(milliseconds: 900),
      );
    });
  });
}
