/// Tracks where playback is between position updates.
///
/// `PlaybackState.position` only ticks at just_audio's cadence (roughly every
/// 200 ms), so a frame stamped straight from it can be up to 200 ms stale —
/// enough to reorder onsets and to make a seek look like ordinary progress.
/// This interpolates from the last update using the ticker's own elapsed
/// time, which brings stamping to within a frame.
///
/// It does **not** shorten the gap between the sound and the tile; nothing on
/// this side of the capture can. It only makes the stamps consistent.
class GameClock {
  Duration _syncedPosition = Duration.zero;
  Duration _syncedAt = Duration.zero;
  Duration _tickerElapsed = Duration.zero;
  double _speed = 1.0;
  bool _running = false;

  /// Monotonic milliseconds since the run started. All tile timing and all
  /// judging happen on this, never on audio position — mixing the two gives
  /// timing that drifts every time playback resyncs.
  double get nowMs => _tickerElapsed.inMicroseconds / 1000.0;

  /// The best current estimate of playback position.
  Duration get audioPosition {
    if (!_running) return _syncedPosition;
    final since = _tickerElapsed - _syncedAt;
    if (since <= Duration.zero) return _syncedPosition;
    return _syncedPosition +
        Duration(microseconds: (since.inMicroseconds * _speed).round());
  }

  /// Feeds the authoritative position whenever playback reports one.
  void sync(Duration position, {double speed = 1.0}) {
    _syncedPosition = position;
    _syncedAt = _tickerElapsed;
    _speed = speed <= 0 ? 1.0 : speed;
  }

  /// Advances from the ticker. Paused ticks are ignored so a paused game
  /// neither advances tiles nor accrues misses.
  void tick(Duration elapsed) {
    if (!_running) {
      // Keep the origin moving with the ticker while paused, so resuming
      // doesn't jump by however long the pause lasted.
      final frozen = elapsed - _tickerElapsed;
      _syncedAt += frozen;
      _tickerElapsed = elapsed;
      return;
    }
    _tickerElapsed = elapsed;
  }

  void resume() => _running = true;
  void pause() => _running = false;

  void reset() {
    _syncedPosition = Duration.zero;
    _syncedAt = _tickerElapsed;
    _speed = 1.0;
  }

  /// Whether playback is running, so callers can skip work while paused.
  bool get isRunning => _running;
}
