import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_capture_service.dart';
import '../../playback/application/playback_controller.dart';
import '../../settings/application/settings_controller.dart';

/// The audio session currently producing sound, or `null` off Android.
final audioSessionIdProvider = StreamProvider<int?>((ref) {
  return ref.watch(audioPlayerServiceProvider).audioSessionIdStream;
});

/// Keeps the native capture bound to the active audio session while the
/// real-time visualizer is switched on, and releases it otherwise.
///
/// The session changes on every crossfade (playback hands over to the other
/// player), so this re-binds rather than assuming one session per track.
/// Its value is whether capture is actually running — the visualizer falls
/// back to its simulated waveform when it isn't.
final audioCaptureBindingProvider = Provider<bool>((ref) {
  final enabled =
      ref.watch(settingsStreamProvider).value?.realtimeVisualizerEnabled ??
      false;
  final service = ref.watch(audioCaptureServiceProvider);
  final sessionId = ref.watch(audioSessionIdProvider).value;

  if (!enabled || sessionId == null) {
    unawaited(service.stop());
    return false;
  }

  // `start` is idempotent for a session already being captured, so a rebuild
  // that doesn't change the id costs nothing.
  unawaited(service.start(sessionId));
  ref.onDispose(() => unawaited(service.stop()));
  return true;
});

/// Live frequency magnitudes, or an empty stream when capture is off.
final audioMagnitudesProvider = StreamProvider<List<double>>((ref) {
  if (!ref.watch(audioCaptureBindingProvider)) {
    return const Stream<List<double>>.empty();
  }
  return ref.watch(audioCaptureServiceProvider).magnitudes;
});
