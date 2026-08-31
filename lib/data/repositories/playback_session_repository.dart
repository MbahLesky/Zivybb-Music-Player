import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/audio_player_service.dart';
import '../datasources/app_database.dart';

/// What was playing when the app was last closed.
class PlaybackSession {
  const PlaybackSession({
    required this.songIds,
    required this.currentIndex,
    required this.position,
    required this.shuffleEnabled,
    required this.repeatMode,
    required this.speed,
    this.sourcePlaylistId,
  });

  final List<String> songIds;
  final int currentIndex;
  final Duration position;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final double speed;
  final String? sourcePlaylistId;

  /// The ID of the track that was playing, or `null` if the saved index no
  /// longer points anywhere (e.g. an empty queue).
  String? get currentSongId =>
      currentIndex >= 0 && currentIndex < songIds.length
      ? songIds[currentIndex]
      : null;
}

/// Persists and restores the playback queue and transport settings, so
/// "resume where I left off" survives the app being closed or killed.
class PlaybackSessionRepository {
  PlaybackSessionRepository({required this._database});

  final AppDatabase _database;

  Future<PlaybackSession?> load() async {
    final row =
        await (_database.select(_database.playbackSessions)
              ..where((t) => t.id.equals(PlaybackSessions.singletonId)))
            .getSingleOrNull();
    if (row == null) return null;

    final decoded = jsonDecode(row.songIdsJson);
    final songIds = decoded is List ? decoded.cast<String>() : <String>[];

    return PlaybackSession(
      songIds: songIds,
      currentIndex: row.currentIndex,
      position: Duration(milliseconds: row.positionMs),
      shuffleEnabled: row.shuffleEnabled,
      // A repeat mode written by a newer build falls back to `off` rather
      // than throwing and losing the whole session.
      repeatMode:
          RepeatMode.values.asNameMap()[row.repeatMode] ?? RepeatMode.off,
      speed: row.speed,
      sourcePlaylistId: row.sourcePlaylistId,
    );
  }

  Future<void> save(PlaybackSession session) {
    final companion = PlaybackSessionsCompanion.insert(
      id: PlaybackSessions.singletonId,
      songIdsJson: Value(jsonEncode(session.songIds)),
      currentIndex: Value(session.currentIndex),
      positionMs: Value(session.position.inMilliseconds),
      shuffleEnabled: Value(session.shuffleEnabled),
      repeatMode: Value(session.repeatMode.name),
      speed: Value(session.speed),
      sourcePlaylistId: Value(session.sourcePlaylistId),
    );
    return _database
        .into(_database.playbackSessions)
        .insert(companion, onConflict: DoUpdate((_) => companion));
  }

  Future<void> clear() {
    return (_database.delete(
      _database.playbackSessions,
    )..where((t) => t.id.equals(PlaybackSessions.singletonId))).go();
  }
}

final playbackSessionRepositoryProvider = Provider<PlaybackSessionRepository>(
  (ref) => PlaybackSessionRepository(database: ref.watch(appDatabaseProvider)),
);
