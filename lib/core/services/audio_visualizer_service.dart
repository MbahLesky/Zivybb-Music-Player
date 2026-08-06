import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dart side of the Android `Visualizer` bridge (see
/// `android/.../AudioVisualizerBridge.kt`).
///
/// Streams real frequency-band levels for the currently playing audio, so the
/// wave visualizer can react to the music instead of animating a simulated
/// waveform. Android-only: every method is a safe no-op elsewhere, and the
/// caller falls back to the simulation.
class AudioVisualizerService {
  static const _methods = MethodChannel('com.lespa.zivybb/visualizer');
  static const _events = EventChannel('com.lespa.zivybb/visualizer_events');

  /// Number of bands the native side emits. Mirrors `BAND_COUNT` there.
  static const bandCount = 32;

  bool get isSupported => Platform.isAndroid;

  /// Normalized 0..1 band levels, low frequencies first.
  Stream<List<double>> get bandStream {
    if (!isSupported) return const Stream.empty();
    return _events.receiveBroadcastStream().map((event) {
      final raw = event as List<Object?>;
      return [for (final value in raw) (value as num).toDouble()];
    });
  }

  /// Attaches the capture to [sessionId].
  ///
  /// Returns false rather than throwing when the effect can't be created —
  /// a revoked permission, a device that doesn't offer it, or another app
  /// already holding the session are all normal and none should interrupt
  /// playback.
  Future<bool> start(int sessionId) async {
    if (!isSupported) return false;
    try {
      final started = await _methods.invokeMethod<bool>('start', {
        'sessionId': sessionId,
      });
      return started ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> stop() async {
    if (!isSupported) return;
    try {
      await _methods.invokeMethod<void>('stop');
    } on PlatformException {
      // Nothing to release, or already gone.
    } on MissingPluginException {
      // Running against a build without the native side.
    }
  }
}

final audioVisualizerServiceProvider = Provider<AudioVisualizerService>(
  (ref) => AudioVisualizerService(),
);
