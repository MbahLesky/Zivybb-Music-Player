import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/system_volume_service.dart';
import '../application/playback_controller.dart';

/// Makes the upper half of Now Playing swipeable: sideways to change track,
/// up and down for volume.
///
/// Wraps only the artwork/title area on purpose. Below it sit the seek bar
/// and the transport rows, where a stray swipe would either scrub the track
/// or fight the slider — so the gesture surface stops where the controls
/// begin.
///
/// Volume moves the *system* media level (the one the hardware keys move),
/// via [SystemVolumeService]; the player's own gain belongs to the crossfade.
/// Where that isn't available — any non-Android platform — the vertical swipe
/// simply does nothing rather than showing an indicator that lies.
class NowPlayingGestureArea extends ConsumerStatefulWidget {
  const NowPlayingGestureArea({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NowPlayingGestureArea> createState() =>
      _NowPlayingGestureAreaState();
}

class _NowPlayingGestureAreaState extends ConsumerState<NowPlayingGestureArea> {
  /// How far a sideways swipe has to travel to count as a track change.
  /// Below this it reads as a slip of the thumb.
  static const _trackSwipeDistance = 60.0;

  /// A drag this long takes the volume from silent to full. Shorter than a
  /// typical artwork slot so the whole range is reachable in one comfortable
  /// gesture.
  static const _fullVolumeDragDistance = 220.0;

  static const _indicatorLinger = Duration(milliseconds: 900);

  double _horizontalDrag = 0;

  /// The volume the current drag is working from, and the live value it has
  /// reached. Null when no drag is in progress or volume isn't available.
  double? _dragStartVolume;
  double? _indicatorVolume;
  Timer? _indicatorTimer;

  @override
  void dispose() {
    _indicatorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => _horizontalDrag = 0,
      onHorizontalDragUpdate: (details) => _horizontalDrag += details.delta.dx,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: (_) => _scheduleIndicatorHide(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          if (_indicatorVolume case final volume?)
            _VolumeIndicator(volume: volume),
        ],
      ),
    );
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final travelled = _horizontalDrag;
    _horizontalDrag = 0;
    if (travelled.abs() < _trackSwipeDistance) return;

    final controller = ref.read(playbackControllerProvider.notifier);
    // Swiping left pulls the next track in from the right, matching how the
    // queue reads left-to-right.
    unawaited(travelled < 0 ? controller.next() : controller.previous());
  }

  Future<void> _onVerticalDragStart(DragStartDetails details) async {
    final volume = await ref.read(systemVolumeServiceProvider).currentVolume();
    if (!mounted || volume == null) return;
    _indicatorTimer?.cancel();
    setState(() {
      _dragStartVolume = volume;
      _indicatorVolume = volume;
    });
  }

  Future<void> _onVerticalDragUpdate(DragUpdateDetails details) async {
    final start = _dragStartVolume;
    final shown = _indicatorVolume;
    if (start == null || shown == null) return;

    // Dragging up raises the volume, so the screen-down delta is inverted.
    final target = (shown - details.delta.dy / _fullVolumeDragDistance).clamp(
      0.0,
      1.0,
    );
    // The system stores volume in whole steps; only talk to it when the
    // change is big enough to actually land on a different one, or a slow
    // drag floods the channel with no-ops.
    if ((target - shown).abs() < 0.01) return;

    setState(() => _indicatorVolume = target);
    final applied = await ref
        .read(systemVolumeServiceProvider)
        .setVolume(target);
    if (!mounted || applied == null) return;
    // Follow where the volume actually landed, not where the finger asked
    // for, so the indicator can't drift away from the real level.
    setState(() => _indicatorVolume = applied);
  }

  void _scheduleIndicatorHide() {
    _dragStartVolume = null;
    _indicatorTimer?.cancel();
    _indicatorTimer = Timer(_indicatorLinger, () {
      if (mounted) setState(() => _indicatorVolume = null);
    });
  }
}

/// The transient volume readout shown over the artwork mid-swipe.
class _VolumeIndicator extends StatelessWidget {
  const _VolumeIndicator({required this.volume});

  final double volume;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final percent = (volume * 100).round();

    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              switch (percent) {
                0 => Icons.volume_off,
                < 50 => Icons.volume_down,
                _ => Icons.volume_up,
              },
              color: scheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 96,
              child: LinearProgressIndicator(
                value: volume,
                minHeight: 4,
                backgroundColor: scheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 8),
            Text('$percent%', style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
