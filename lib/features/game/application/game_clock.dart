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
///
/// Game time is accumulated from ticker *deltas* rather than read off the
/// ticker directly. The ticker keeps counting while playback is paused, and
/// taking its value as game time meant a paused game carried on: every tile in
/// flight fell to the hit line, expired, and was scored as a miss while the
/// music sat still.
class GameClock {
  Duration _syncedPosition = Duration.zero;

  /// Game time at the last [sync].
  Duration _syncedAt = Duration.zero;

  /// Time the game has actually been running. Frozen while paused.
  Duration _gameElapsed = Duration.zero;

  /// The last raw ticker value, so [tick] can work in deltas.
  Duration _lastTicker = Duration.zero;

  double _speed = 1.0;
  bool _running = false;

  /// Monotonic milliseconds the game has been running. All tile timing and
  /// all judging happen on this, never on audio position — mixing the two
  /// gives timing that drifts every time playback resyncs.
  double get nowMs => _gameElapsed.inMicroseconds / 1000.0;

  /// The best current estimate of playback position.
  Duration get audioPosition {
    if (!_running) return _syncedPosition;
    final since = _gameElapsed - _syncedAt;
    if (since <= Duration.zero) return _syncedPosition;
    return _syncedPosition +
        Duration(microseconds: (since.inMicroseconds * _speed).round());
  }

  /// Feeds the authoritative position whenever playback reports one.
  void sync(Duration position, {double speed = 1.0}) {
    _syncedPosition = position;
    _syncedAt = _gameElapsed;
    _speed = speed <= 0 ? 1.0 : speed;
  }

  /// Advances from the ticker.
  ///
  /// Paused frames move nothing: the delta is swallowed, so a paused game
  /// neither advances tiles nor accrues misses, and resuming picks up exactly
  /// where it left off however long the pause was.
  void tick(Duration elapsed) {
    final delta = elapsed - _lastTicker;
    _lastTicker = elapsed;
    if (!_running || delta <= Duration.zero) return;
    _gameElapsed += delta;
  }

  void resume() => _running = true;
  void pause() => _running = false;

  /// Starts a fresh run's position tracking. Game time itself keeps counting:
  /// tiles already carry absolute game-time arrivals, and rewinding it would
  /// make every one of them look overdue.
  void reset() {
    _syncedPosition = Duration.zero;
    _syncedAt = _gameElapsed;
    _speed = 1.0;
  }

  /// Whether playback is running, so callers can skip work while paused.
  bool get isRunning => _running;
}
