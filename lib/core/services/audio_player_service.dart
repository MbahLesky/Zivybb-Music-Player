import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

import '../../data/models/song.dart';

/// Thin wrapper around the underlying audio engine ([AudioPlayer]).
///
/// Keeps `just_audio` out of the feature/application layer so the engine
/// can be swapped later without touching playback controllers.
class AudioPlayerService {
  /// Builds the real player (with an Android equalizer attached, since V1
  /// targets Android — SRS 2.3) or wraps an injected [player] for tests,
  /// which gets no equalizer.
  factory AudioPlayerService({AudioPlayer? player}) {
    if (player != null) {
      return AudioPlayerService._(player, null);
    }
    final equalizer = Platform.isAndroid ? AndroidEqualizer() : null;
    final newPlayer = AudioPlayer(
      audioPipeline: AudioPipeline(
        androidAudioEffects: [?equalizer],
      ),
    );
    return AudioPlayerService._(newPlayer, equalizer);
  }

  AudioPlayerService._(this._player, this._equalizer) {
    _crossfadeSubscription = _player.positionStream.listen(
      _maybeApplyCrossfadeVolume,
    );
    _errorSubscription = _player.errorStream.listen(_onPlayerError);
  }

  final AudioPlayer _player;
  final AndroidEqualizer? _equalizer;
  late final StreamSubscription<Duration> _crossfadeSubscription;
  late final StreamSubscription<PlayerException> _errorSubscription;
  final _errorIndexController = StreamController<int>.broadcast();

  bool _crossfadeEnabled = false;
  Duration _crossfadeDuration = const Duration(seconds: 3);

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.playerStateStream.map((state) => state.processingState);

  /// Emits the queue index of a track that failed to play (SRS F-5.3), e.g.
  /// because its file was deleted.
  Stream<int> get playbackErrorIndexStream => _errorIndexController.stream;

  bool get isShuffleModeEnabled => _player.shuffleModeEnabled;

  void _onPlayerError(PlayerException error) {
    final index = error.index ?? _player.currentIndex;
    if (index != null) {
      _errorIndexController.add(index);
    }
  }

  /// Loads [queue] into the engine as a gapless playlist and starts playback
  /// at [initialIndex].
  Future<void> loadQueue(List<Song> queue, {int initialIndex = 0}) async {
    await _player.setAudioSources([
      for (final song in queue) AudioSource.uri(Uri.file(song.filePath)),
    ], initialIndex: initialIndex);
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> seekToNext() => _player.seekToNext();

  Future<void> seekToPrevious() => _player.seekToPrevious();

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> setShuffleModeEnabled(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
    if (enabled) {
      await _player.shuffle();
    }
  }

  /// Configures the fade applied around track boundaries (SRS F-1.4).
  ///
  /// This is a same-engine volume fade at the boundary between consecutive
  /// gapless tracks, not two tracks playing simultaneously — a single
  /// `just_audio` engine can't overlap two audio sources. In practice it
  /// reads as a smooth transition for the common case of letting one track
  /// run into the next.
  void setCrossfadeSettings({
    required bool enabled,
    required Duration duration,
  }) {
    _crossfadeEnabled = enabled;
    _crossfadeDuration = duration;
    if (!enabled) {
      _player.setVolume(1);
    }
  }

  void _maybeApplyCrossfadeVolume(Duration position) {
    if (!_crossfadeEnabled) return;
    final duration = _player.duration;
    if (duration == null ||
        duration <= Duration.zero ||
        _crossfadeDuration <= Duration.zero) {
      return;
    }

    final fadeInEnd = _crossfadeDuration;
    final fadeOutStart = duration - _crossfadeDuration;

    var volume = 1.0;
    if (position <= fadeInEnd) {
      volume = position.inMilliseconds / fadeInEnd.inMilliseconds;
    } else if (position >= fadeOutStart) {
      final remaining = duration - position;
      volume = remaining.inMilliseconds / _crossfadeDuration.inMilliseconds;
    }
    _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// Whether a real equalizer is available (Android only — SRS 2.3).
  bool get hasEqualizer => _equalizer != null;

  /// Applies [bandGains] (in dB) to the device equalizer and enables it. If
  /// the device exposes a different number of bands than `bandGains.length`
  /// (band count/frequencies are device-specific and only known at
  /// runtime), each device band samples the nearest entry in [bandGains].
  /// No-ops if no equalizer is available (SRS F-1.6).
  Future<void> applyEqualizerBandGains(List<double> bandGains) async {
    final equalizer = _equalizer;
    if (equalizer == null || bandGains.isEmpty) return;

    await equalizer.setEnabled(true);
    final parameters = await equalizer.parameters;
    for (final band in parameters.bands) {
      final t = parameters.bands.length <= 1
          ? 0.0
          : band.index / (parameters.bands.length - 1);
      final sourceIndex = (t * (bandGains.length - 1)).round();
      await band.setGain(
        bandGains[sourceIndex].clamp(
          parameters.minDecibels,
          parameters.maxDecibels,
        ),
      );
    }
  }

  Future<void> disableEqualizer() =>
      _equalizer?.setEnabled(false) ?? Future.value();

  Future<void> dispose() async {
    await _crossfadeSubscription.cancel();
    await _errorSubscription.cancel();
    await _errorIndexController.close();
    await _player.dispose();
  }
}
