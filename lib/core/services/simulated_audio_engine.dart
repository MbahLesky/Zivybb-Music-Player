import 'dart:async';

import '../../data/models/song.dart';
import 'audio_engine.dart';

/// An [AudioEngine] that advances a clock instead of producing sound.
///
/// This is a stand-in so the transport controls, progress bar, and queue
/// advance can be built and tested before the real audio package is added
/// (Development Plan, Week 1 Day 4). It plays nothing — replacing it is the
/// next playback task, and nothing outside this file should assume it exists.
class SimulatedAudioEngine implements AudioEngine {
  SimulatedAudioEngine({this.tick = const Duration(milliseconds: 200)});

  /// How often the simulated position advances.
  final Duration tick;

  final _positionController = StreamController<Duration>.broadcast();
  final _completionController = StreamController<void>.broadcast();

  Timer? _timer;
  Duration _position = Duration.zero;
  Duration _trackDuration = Duration.zero;

  @override
  Duration get position => _position;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<void> get trackCompletions => _completionController.stream;

  @override
  Future<void> load(Song song) async {
    _timer?.cancel();
    _timer = null;
    _trackDuration = song.duration;
    _emitPosition(Duration.zero);
  }

  @override
  Future<void> play() async {
    if (_timer != null) return;
    _timer = Timer.periodic(tick, (_) => _advance());
  }

  @override
  Future<void> pause() async {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> seek(Duration position) async {
    final clamped = position < Duration.zero
        ? Duration.zero
        : (position > _trackDuration ? _trackDuration : position);
    _emitPosition(clamped);
  }

  @override
  Future<void> dispose() async {
    _timer?.cancel();
    _timer = null;
    await _positionController.close();
    await _completionController.close();
  }

  void _advance() {
    final next = _position + tick;
    if (next >= _trackDuration) {
      _emitPosition(_trackDuration);
      pause();
      _completionController.add(null);
      return;
    }
    _emitPosition(next);
  }

  void _emitPosition(Duration position) {
    _position = position;
    if (!_positionController.isClosed) _positionController.add(position);
  }
}
