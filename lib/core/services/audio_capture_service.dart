import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Live frequency magnitudes from the app's own playback, for the
/// beat-reactive visualizer (SRS F-1.5).
///
/// Android's `Visualizer` effect is classed as audio capture, so this needs
/// the microphone permission even though it only ever reads Zivybb's own
/// output — never the mic. Every failure path (permission refused, effect
/// unavailable, non-Android platform) reports "not capturing" so the
/// visualizer can fall back to its simulated waveform rather than going
/// blank.
class AudioCaptureService {
  AudioCaptureService({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  }) : _methodChannel =
           methodChannel ?? const MethodChannel(_methodChannelName),
       _eventChannel = eventChannel ?? const EventChannel(_eventChannelName);

  static const _methodChannelName = 'com.lespa.zivybb/audio_capture';
  static const _eventChannelName = 'com.lespa.zivybb/audio_capture_events';

  /// Must match `AudioCapturePlugin.BAND_COUNT` on the Android side.
  static const bandCount = 24;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Stream<List<double>>? _magnitudes;

  /// Requests the permission Android requires for the capture effect.
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      return status.isGranted;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  /// Binds the capture to [sessionId], returning whether it started.
  ///
  /// Safe to call repeatedly with the same id — the platform side keeps the
  /// existing capture. Playback hands over to a different session on every
  /// crossfade, so callers re-issue this whenever the id changes.
  Future<bool> start(int sessionId) async {
    try {
      final started = await _methodChannel.invokeMethod<bool>('start', {
        'sessionId': sessionId,
      });
      return started ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _methodChannel.invokeMethod<void>('stop');
    } on MissingPluginException {
      // Nothing was ever started.
    } on PlatformException {
      // Already stopped or released.
    }
  }

  /// Emits [bandCount] magnitudes in 0..1, low frequencies first.
  ///
  /// Broadcast and cached so the mini player and Now Playing can both draw
  /// from a single native capture.
  Stream<List<double>> get magnitudes {
    return _magnitudes ??= _eventChannel
        .receiveBroadcastStream()
        .map(
          (event) => (event as List<Object?>)
              .map((v) => (v as num).toDouble())
              .toList(growable: false),
        )
        .handleError((Object _) {})
        .asBroadcastStream();
  }
}

final audioCaptureServiceProvider = Provider<AudioCaptureService>(
  (ref) => AudioCaptureService(),
);
