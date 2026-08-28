import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// How well a tap landed on its tile.
enum HitJudgement {
  perfect,
  great,
  good,
  miss;

  String get label => switch (this) {
    HitJudgement.perfect => 'Perfect',
    HitJudgement.great => 'Great',
    HitJudgement.good => 'Good',
    HitJudgement.miss => 'Miss',
  };
}

/// Timing windows and combo rules.
///
/// The windows are wide for a rhythm game on purpose: this is a mini-game
/// inside a music player, and the capture pipeline already puts a real gap
/// between the sound and the tile (see `RhythmGameScreen`), so tight windows
/// would punish the player for latency they cannot do anything about.
@immutable
class ScoringConfig {
  const ScoringConfig({
    this.perfectWindow = const Duration(milliseconds: 90),
    this.greatWindow = const Duration(milliseconds: 160),
    this.goodWindow = const Duration(milliseconds: 250),
    this.comboStep = 10,
    this.comboStepBonus = 0.5,
    this.maxMultiplier = 3.5,
  });

  final Duration perfectWindow;
  final Duration greatWindow;
  final Duration goodWindow;

  /// Hits per multiplier step.
  final int comboStep;
  final double comboStepBonus;
  final double maxMultiplier;
}

/// Judges a tap by how far it landed from the tile's hit time.
///
/// [error] is `tap - hit`, so negative is early and positive is late; only
/// the magnitude matters.
HitJudgement judgeHit(
  Duration error, {
  ScoringConfig config = const ScoringConfig(),
}) {
  final magnitude = error.isNegative ? -error : error;
  if (magnitude <= config.perfectWindow) return HitJudgement.perfect;
  if (magnitude <= config.greatWindow) return HitJudgement.great;
  if (magnitude <= config.goodWindow) return HitJudgement.good;
  return HitJudgement.miss;
}

/// Points for one hit, before it is folded into a [RunScore].
///
/// Longer beats are worth more — the user asked for tile length to follow the
/// beat, so length has to be worth something or it is only decoration.
int pointsFor({
  required HitJudgement judgement,
  required int comboBefore,
  required Duration sustain,
  ScoringConfig config = const ScoringConfig(),
}) {
  final base = switch (judgement) {
    HitJudgement.perfect => 300,
    HitJudgement.great => 200,
    HitJudgement.good => 100,
    HitJudgement.miss => 0,
  };
  if (base == 0) return 0;

  final lengthBonus = (sustain.inMilliseconds / 100).round();
  final steps = comboBefore ~/ config.comboStep;
  final multiplier = math.min(
    1 + steps * config.comboStepBonus,
    config.maxMultiplier,
  );
  return ((base + lengthBonus) * multiplier).round();
}

/// The running result of one song's playthrough.
@immutable
class RunScore {
  const RunScore({
    this.score = 0,
    this.combo = 0,
    this.bestCombo = 0,
    this.perfects = 0,
    this.greats = 0,
    this.goods = 0,
    this.misses = 0,
    this.strays = 0,
  });

  final int score;
  final int combo;
  final int bestCombo;
  final int perfects;
  final int greats;
  final int goods;
  final int misses;

  /// Taps in a lane with no tile in reach. They score nothing and break the
  /// combo — without that, holding down all four lanes would be the optimal
  /// strategy and every score would be meaningless.
  final int strays;

  int get judged => perfects + greats + goods + misses;

  /// Share of judged tiles that were hit at all, 0..1. Zero (not NaN) before
  /// anything has been judged.
  double get accuracy {
    if (judged == 0) return 0;
    return (perfects + greats + goods) / judged;
  }

  RunScore applyHit(
    HitJudgement judgement,
    Duration sustain, {
    ScoringConfig config = const ScoringConfig(),
  }) {
    if (judgement == HitJudgement.miss) return applyMiss();
    final gained = pointsFor(
      judgement: judgement,
      comboBefore: combo,
      sustain: sustain,
      config: config,
    );
    final nextCombo = combo + 1;
    return _copy(
      score: score + gained,
      combo: nextCombo,
      bestCombo: nextCombo > bestCombo ? nextCombo : bestCombo,
      perfects: perfects + (judgement == HitJudgement.perfect ? 1 : 0),
      greats: greats + (judgement == HitJudgement.great ? 1 : 0),
      goods: goods + (judgement == HitJudgement.good ? 1 : 0),
    );
  }

  /// A tile reached the end untapped. No penalty beyond losing the combo —
  /// the player had no reliable audible cue for it.
  RunScore applyMiss() => _copy(combo: 0, misses: misses + 1);

  RunScore applyStray() => _copy(combo: 0, strays: strays + 1);

  RunScore _copy({
    int? score,
    int? combo,
    int? bestCombo,
    int? perfects,
    int? greats,
    int? goods,
    int? misses,
    int? strays,
  }) {
    return RunScore(
      score: score ?? this.score,
      combo: combo ?? this.combo,
      bestCombo: bestCombo ?? this.bestCombo,
      perfects: perfects ?? this.perfects,
      greats: greats ?? this.greats,
      goods: goods ?? this.goods,
      misses: misses ?? this.misses,
      strays: strays ?? this.strays,
    );
  }
}
