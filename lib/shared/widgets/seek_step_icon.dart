import 'package:flutter/material.dart';

/// The seek-back/forward glyph for a given step size.
///
/// Material ships dedicated `replay_N` / `forward_N` icons only for 5, 10 and
/// 30 seconds. Other steps (15s, and anything added later) fall back to a
/// circular arrow with the number drawn inside it — the same idea the
/// dedicated glyphs use — so the button always states its own step instead of
/// showing a bare arrow whose duration is only discoverable via its tooltip.
class SeekStepIcon extends StatelessWidget {
  const SeekStepIcon({
    super.key,
    required this.seconds,
    required this.forward,
    this.size = 28,
  });

  final int seconds;

  /// Forward glyphs are the mirror image of the back ones, matching how
  /// `forward_N` mirrors `replay_N`.
  final bool forward;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dedicated = _dedicatedIcon;
    if (dedicated != null) return Icon(dedicated, size: size);

    final arrow = Transform.scale(
      scaleX: forward ? -1 : 1,
      child: Icon(Icons.replay, size: size),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        arrow,
        // Sized off the icon so it stays centered in the arrow's ring at any
        // icon size, and excluded from semantics — the button's own label
        // already announces the duration.
        ExcludeSemantics(
          child: Text(
            '$seconds',
            style: TextStyle(
              fontSize: size * 0.36,
              fontWeight: FontWeight.w700,
              height: 1,
              color: IconTheme.of(context).color,
            ),
          ),
        ),
      ],
    );
  }

  IconData? get _dedicatedIcon => switch ((seconds, forward)) {
    (5, false) => Icons.replay_5,
    (10, false) => Icons.replay_10,
    (30, false) => Icons.replay_30,
    (5, true) => Icons.forward_5,
    (10, true) => Icons.forward_10,
    (30, true) => Icons.forward_30,
    _ => null,
  };
}
