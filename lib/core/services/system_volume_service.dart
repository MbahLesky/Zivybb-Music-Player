import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reads and sets the device's media volume.
///
/// Backed by a small `AudioManager` channel on Android rather than the
/// player's own gain: `just_audio`'s volume is what the crossfade ramps
/// drive, so a user-facing control sharing it would be fought by every fade.
/// Platforms with no handler registered (and tests) report volume as
/// unavailable instead of throwing.
class SystemVolumeService {
  SystemVolumeService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'com.lespa.zivybb/system_volume';

  final MethodChannel _channel;

  /// The current media volume as 0..1, or null where there is no handler.
  Future<double?> currentVolume() => _invoke('getVolume');

  /// Sets the media volume from a 0..1 [level], returning where it actually
  /// landed — the system works in whole steps, so the value comes back
  /// rounded and an on-screen indicator should follow the answer rather than
  /// the request.
  Future<double?> setVolume(double level) =>
      _invoke('setVolume', {'level': level.clamp(0.0, 1.0)});

  Future<double?> _invoke(String method, [Map<String, Object?>? args]) async {
    try {
      final value = await _channel.invokeMethod<double>(method, args);
      return value;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}

final systemVolumeServiceProvider = Provider<SystemVolumeService>(
  (ref) => SystemVolumeService(),
);
