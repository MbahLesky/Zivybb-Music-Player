import 'package:flutter/foundation.dart';

/// A tile on its way down the board.
@immutable
class GameTile {
  const GameTile({
    required this.id,
    required this.lane,
    required this.spawnMs,
    required this.hitMs,
    required this.sustain,
    required this.level,
    required this.strength,
  });

  final int id;
  final int lane;

  /// Game-clock time the tile appeared and the time its head reaches the hit
  /// line. Both on [GameClock.nowMs] — never audio position.
  final double spawnMs;
  final double hitMs;

  final Duration sustain;
  final double level;
  final double strength;
}

/// Pure layout maths for the board, kept out of the painter so it can be
/// tested without a canvas.
abstract final class TileGeometry {
  /// Default time a tile takes to fall from the top to the hit line.
  static const defaultTravel = Duration(milliseconds: 900);

  /// Shortest a tile may be drawn, so even a clipped stab stays thumb-sized.
  static const minimumLengthPx = 48.0;

  /// Where the tile's leading edge sits now. Equals [hitLineY] exactly at
  /// `hitMs`, above it before, below it after.
  static double headY({
    required double nowMs,
    required double hitMs,
    required double travelMs,
    required double hitLineY,
  }) {
    if (travelMs <= 0) return hitLineY;
    final remaining = hitMs - nowMs;
    return hitLineY - (remaining / travelMs) * hitLineY;
  }

  /// Tile length, taken straight from the beat's sustain so a held note reads
  /// as a long tile and a stab as a short one.
  static double lengthPx({
    required Duration sustain,
    required double travelMs,
    required double hitLineY,
  }) {
    if (travelMs <= 0 || hitLineY <= 0) return minimumLengthPx;
    final proportional = sustain.inMilliseconds / travelMs * hitLineY;
    return proportional < minimumLengthPx ? minimumLengthPx : proportional;
  }

  /// Whether the tile has fallen past the point where it could still be hit.
  static bool isExpired({
    required double nowMs,
    required double hitMs,
    required Duration goodWindow,
  }) {
    return nowMs > hitMs + goodWindow.inMilliseconds;
  }

  /// Rounds the fall so a tile spawned on one beat lands on a later one.
  ///
  /// The capture only reports audio that has already played, so a tile can
  /// never land on the beat that created it. Snapping the fall to a whole
  /// number of beat periods means it lands on a *subsequent* beat instead, so
  /// tapping with the tiles is still tapping in time with the music. Falls
  /// back to [preferred] when no reliable period is known — a wrong period is
  /// worse than none, since it puts every tile confidently off the beat.
  static Duration quantiseTravel(
    Duration preferred,
    Duration? beatPeriod, {
    Duration minimum = const Duration(milliseconds: 450),
    Duration maximum = const Duration(milliseconds: 1600),
  }) {
    if (beatPeriod == null || beatPeriod <= Duration.zero) return preferred;
    final periodMs = beatPeriod.inMilliseconds;
    final steps = (preferred.inMilliseconds / periodMs).round();
    if (steps < 1) return preferred;
    final snapped = Duration(milliseconds: steps * periodMs);
    if (snapped < minimum || snapped > maximum) return preferred;
    return snapped;
  }
}

/// Estimates the beat period from the gaps between recent onsets.
///
/// A histogram rather than an average: an average over onsets that include
/// off-beat hits lands between the real period and nothing useful, while the
/// modal gap survives them. Returns null until enough gaps agree, because
/// feeding a wrong period into [TileGeometry.quantiseTravel] is worse than
/// feeding none.
Duration? estimateBeatPeriod(
  List<Duration> onsetPositions, {
  int minimumAgreeing = 4,
  Duration shortest = const Duration(milliseconds: 250),
  Duration longest = const Duration(milliseconds: 1000),
  Duration bucketSize = const Duration(milliseconds: 25),
}) {
  if (onsetPositions.length < minimumAgreeing + 1) return null;

  final buckets = <int, int>{};
  for (var i = 1; i < onsetPositions.length; i++) {
    final gap = onsetPositions[i] - onsetPositions[i - 1];
    if (gap < shortest || gap > longest) continue;
    final bucket = gap.inMilliseconds ~/ bucketSize.inMilliseconds;
    buckets[bucket] = (buckets[bucket] ?? 0) + 1;
  }
  if (buckets.isEmpty) return null;

  var bestBucket = -1;
  var bestCount = 0;
  buckets.forEach((bucket, count) {
    if (count > bestCount) {
      bestBucket = bucket;
      bestCount = count;
    }
  });
  if (bestCount < minimumAgreeing) return null;

  // Middle of the winning bucket.
  final ms =
      bestBucket * bucketSize.inMilliseconds + bucketSize.inMilliseconds ~/ 2;
  return Duration(milliseconds: ms);
}
