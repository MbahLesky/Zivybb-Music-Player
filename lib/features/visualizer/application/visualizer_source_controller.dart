import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/audio_visualizer_service.dart';
import '../../../data/models/app_settings.dart';
import '../../playback/application/playback_controller.dart';
import '../../settings/application/settings_controller.dart';

/// The most recent real frequency-band levels, or `null` when there is no
/// live feed — because the user hasn't opted in, the platform can't provide
/// one, or nothing is playing.
///
/// A `null` here is the visualizer's cue to fall back to the simulated
/// waveform, so the UI never has to know which source it is drawing.
class VisualizerSourceController extends Notifier<List<double>?> {
  StreamSubscription<List<double>>? _bands;
  int? _attachedSession;

  /// Serializes attach/detach so two rapid changes (say, the crossfade
  /// engine swapping sessions just as playback pauses) can't interleave and
  /// leave a capture running against a stale session.
  Future<void> _work = Future.value();

  @override
  List<double>? build() {
    final service = ref.read(audioVisualizerServiceProvider);

    // Both inputs matter: the opt-in plus whether anything is playing, and
    // the session ID, which changes as the crossfade engine hands off
    // between its two players.
    ref.listen(
      _captureRequestedProvider,
      (_, _) => _requestSync(service),
      fireImmediately: true,
    );
    ref.listen(
      _androidAudioSessionIdProvider,
      (_, _) => _requestSync(service),
      fireImmediately: true,
    );

    ref.onDispose(() {
      _bands?.cancel();
      service.stop();
    });

    return null;
  }

  void _requestSync(AudioVisualizerService service) {
    _work = _work.then((_) => _sync(service)).catchError((Object _) {});
  }

  Future<void> _sync(AudioVisualizerService service) async {
    final wanted = ref.read(_captureRequestedProvider);
    final sessionId = ref.read(_androidAudioSessionIdProvider).value;

    if (!wanted || sessionId == null) {
      await _detach(service);
      return;
    }
    if (sessionId == _attachedSession) return;

    await _detach(service);
    if (!await service.start(sessionId)) return;

    _attachedSession = sessionId;
    _bands = service.bandStream.listen(
      (bands) => state = bands,
      // A capture that dies mid-track — session torn down, or the
      // permission revoked from system Settings while running — drops back
      // to the simulation instead of freezing on its last frame.
      onError: (Object _) => _requestSync(service),
      onDone: () => _requestSync(service),
      cancelOnError: true,
    );
  }

  Future<void> _detach(AudioVisualizerService service) async {
    await _bands?.cancel();
    _bands = null;
    _attachedSession = null;
    state = null;
    await service.stop();
  }
}

final visualizerSourceControllerProvider =
    NotifierProvider<VisualizerSourceController, List<double>?>(
      VisualizerSourceController.new,
    );

/// Whether a live capture should be running: the user opted in, the platform
/// supports it, and something is actually playing.
final _captureRequestedProvider = Provider<bool>((ref) {
  if (!ref.watch(audioVisualizerServiceProvider).isSupported) return false;
  final settings =
      ref.watch(settingsStreamProvider).value ?? const AppSettings();
  if (!settings.realVisualizerEnabled) return false;
  return ref.watch(playbackControllerProvider).isPlaying;
});

final _androidAudioSessionIdProvider = StreamProvider<int?>((ref) {
  return ref.watch(audioPlayerServiceProvider).androidAudioSessionIdStream;
});

/// Whether the visualizer is drawing real audio rather than the simulation —
/// surfaced in Settings so the opt-in isn't a black box.
final realVisualizerActiveProvider = Provider<bool>((ref) {
  return ref.watch(visualizerSourceControllerProvider) != null;
});
