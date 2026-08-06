import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'playback_controller.dart';

/// Preset durations offered in the sleep-timer picker.
const sleepTimerPresets = [
  Duration(minutes: 5),
  Duration(minutes: 15),
  Duration(minutes: 30),
  Duration(minutes: 45),
  Duration(minutes: 60),
  Duration(minutes: 90),
];

/// State of the sleep timer: how long is left, and whether the current track
/// gets to finish once the clock runs out.
class SleepTimerState {
  const SleepTimerState({this.remaining, this.finishCurrentTrack = false});

  /// `null` when no timer is armed.
  final Duration? remaining;

  /// When set, hitting zero waits for the current track to end rather than
  /// cutting it off mid-song.
  final bool finishCurrentTrack;

  bool get isActive => remaining != null;
}

/// Pauses playback after a chosen delay (a bedtime staple: start an album,
/// fall asleep, and the phone goes quiet on its own).
///
/// Counts down in real time so the UI can show the remaining minutes, and
/// pauses rather than stops so resuming picks up exactly where it left off.
class SleepTimerController extends Notifier<SleepTimerState> {
  Timer? _ticker;

  @override
  SleepTimerState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const SleepTimerState();
  }

  void start(Duration duration, {bool finishCurrentTrack = false}) {
    _ticker?.cancel();
    state = SleepTimerState(
      remaining: duration,
      finishCurrentTrack: finishCurrentTrack,
    );
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void cancel() {
    _ticker?.cancel();
    _ticker = null;
    state = const SleepTimerState();
  }

  void _tick() {
    final remaining = state.remaining;
    if (remaining == null) {
      cancel();
      return;
    }

    final next = remaining - const Duration(seconds: 1);
    if (next > Duration.zero) {
      state = SleepTimerState(
        remaining: next,
        finishCurrentTrack: state.finishCurrentTrack,
      );
      return;
    }

    if (state.finishCurrentTrack) {
      _pauseAfterCurrentTrack();
    } else {
      ref.read(playbackControllerProvider.notifier).pause();
      cancel();
    }
  }

  /// Holds the timer at zero and waits for the track to end, then pauses.
  ///
  /// "Ended" is detected by the queue index moving on rather than by a
  /// processing-state event, since gapless and crossfade transitions both
  /// roll straight into the next track without ever reporting completion.
  void _pauseAfterCurrentTrack() {
    _ticker?.cancel();
    _ticker = null;
    state = const SleepTimerState(
      remaining: Duration.zero,
      finishCurrentTrack: true,
    );

    final startingIndex = ref.read(playbackControllerProvider).currentIndex;
    late final ProviderSubscription<PlaybackState> subscription;
    subscription = ref.listen<PlaybackState>(playbackControllerProvider, (
      previous,
      next,
    ) {
      if (next.currentIndex == startingIndex) return;
      subscription.close();
      ref.read(playbackControllerProvider.notifier).pause();
      cancel();
    });
  }
}

final sleepTimerControllerProvider =
    NotifierProvider<SleepTimerController, SleepTimerState>(
      SleepTimerController.new,
    );
