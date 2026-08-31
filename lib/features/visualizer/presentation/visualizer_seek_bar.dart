import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/song.dart';
import '../../../shared/widgets/song_artwork.dart';
import '../../settings/application/settings_controller.dart';
import 'wave_visualizer.dart';

/// The fraction of [duration] that [position] represents, in `[0, 1]`.
double progressFraction(Duration position, Duration duration) {
  if (duration <= Duration.zero) return 0;
  final fraction = position.inMilliseconds / duration.inMilliseconds;
  return fraction.isFinite ? fraction.clamp(0.0, 1.0) : 0.0;
}

/// The visualizer standing in for the progress bar, read left to right.
///
/// Not the visualizer drawn *behind* a slider — that is what this replaced.
/// The wave itself is the track: the played part is drawn in the visualizer
/// colour and the rest in grey, and dragging anywhere across it scrubs.
///
/// Used for the styles that already read horizontally (bars, mirror, line,
/// ribbon); see [VisualizerStyle.seekBarShape].
class VisualizerTrackSeekBar extends ConsumerStatefulWidget {
  const VisualizerTrackSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.height = 64,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final double height;

  @override
  ConsumerState<VisualizerTrackSeekBar> createState() =>
      _VisualizerTrackSeekBarState();
}

class _VisualizerTrackSeekBarState
    extends ConsumerState<VisualizerTrackSeekBar> {
  /// Where the thumb sits mid-drag. The wave keeps following playback while
  /// the finger is down, but the marker has to follow the finger or scrubbing
  /// feels unanchored.
  double? _dragFraction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fraction =
        _dragFraction ?? progressFraction(widget.position, widget.duration);

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          void scrubTo(double dx) {
            final next = (dx / constraints.maxWidth).clamp(0.0, 1.0);
            setState(() => _dragFraction = next);
          }

          void commit() {
            final at = _dragFraction;
            setState(() => _dragFraction = null);
            if (at == null) return;
            widget.onSeek(
              Duration(
                milliseconds: (widget.duration.inMilliseconds * at).round(),
              ),
            );
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => scrubTo(details.localPosition.dx),
            onTapUp: (_) => commit(),
            onTapCancel: () => setState(() => _dragFraction = null),
            onHorizontalDragStart: (details) =>
                scrubTo(details.localPosition.dx),
            onHorizontalDragUpdate: (details) =>
                scrubTo(details.localPosition.dx),
            onHorizontalDragEnd: (_) => commit(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                WaveVisualizer(
                  color: ref.watch(visualizerColorProvider),
                  height: widget.height,
                  progress: fraction,
                  unplayedColor: scheme.onSurfaceVariant.withValues(
                    alpha: 0.32,
                  ),
                ),
                // A slim marker at the playhead. Without it the boundary
                // between played and unplayed is only as legible as the wave
                // happens to be at that instant, which at a quiet moment is
                // not at all.
                Align(
                  alignment: Alignment(fraction * 2 - 1, 0),
                  child: Container(
                    width: 2,
                    height: widget.height,
                    color: scheme.primary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The visualizer as a ring around the artwork, read clockwise from the top.
///
/// The circular styles (radial, particles) leave a hole in the middle, so
/// standing in for the seek bar means taking the artwork slot and putting the
/// artwork inside the ring rather than hiding it.
///
/// Dragging around the ring scrubs; the artwork in the centre is left alone,
/// so a tap there can't fling the track somewhere unintended.
class VisualizerRingSeekBar extends ConsumerStatefulWidget {
  const VisualizerRingSeekBar({
    super.key,
    required this.song,
    required this.size,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.showArtwork = true,
  });

  final Song song;
  final double size;
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  /// Whether the artwork is drawn in the middle. Off leaves the hole empty,
  /// for the user who turned album art off on this screen.
  final bool showArtwork;

  /// Where `RadialPainter` puts the inner edge of its spokes, as a fraction of
  /// the radius. The artwork has to fit inside that, and touches inside it
  /// are the artwork's, not the ring's.
  static const innerRadiusFraction = 0.38;

  @override
  ConsumerState<VisualizerRingSeekBar> createState() =>
      _VisualizerRingSeekBarState();
}

class _VisualizerRingSeekBarState extends ConsumerState<VisualizerRingSeekBar> {
  double? _dragFraction;

  @override
  Widget build(BuildContext context) {
    final size = widget.size <= 0 ? 0.0 : widget.size;
    final fraction =
        _dragFraction ?? progressFraction(widget.position, widget.duration);
    // Sized to the flat sides of the square the ring is inscribed in, with a
    // little clearance so the art never touches the spokes.
    final artSize = size * VisualizerRingSeekBar.innerRadiusFraction * 2 * 0.92;

    return SizedBox(
      width: size,
      height: size,
      child: GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onPanStart: (details) => _scrub(details.localPosition, size),
        onPanUpdate: (details) => _scrub(details.localPosition, size),
        onPanEnd: (_) => _commit(),
        child: Stack(
          alignment: Alignment.center,
          children: [
            WaveVisualizer(
              color: ref.watch(visualizerColorProvider),
              height: size,
              progress: fraction,
              unplayedColor: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.32),
            ),
            if (widget.showArtwork && artSize > 0)
              ClipOval(
                child: SongArtwork(
                  song: widget.song,
                  size: artSize,
                  borderRadius: artSize / 2,
                  iconSize: artSize * 0.35,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _scrub(Offset local, double size) {
    if (size <= 0) return;
    final centre = Offset(size / 2, size / 2);
    final vector = local - centre;
    // Inside the artwork is not the track. Ignoring it here also means the
    // gesture never starts, so a tap on the art stays a tap on the art.
    final inner = size / 2 * VisualizerRingSeekBar.innerRadiusFraction;
    if (vector.distance < inner) return;

    // atan2 measures from three o'clock counter-clockwise; the ring is read
    // from twelve o'clock clockwise, which is that rotated a quarter turn.
    final angle = math.atan2(vector.dy, vector.dx) + math.pi / 2;
    final normalised = (angle % (2 * math.pi)) / (2 * math.pi);
    setState(() => _dragFraction = normalised.clamp(0.0, 1.0));
  }

  void _commit() {
    final at = _dragFraction;
    setState(() => _dragFraction = null);
    if (at == null) return;
    widget.onSeek(
      Duration(milliseconds: (widget.duration.inMilliseconds * at).round()),
    );
  }
}
