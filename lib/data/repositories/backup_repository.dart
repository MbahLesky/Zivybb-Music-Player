import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../datasources/app_database.dart';
import '../models/app_settings.dart';
import 'playlist_repository.dart';
import 'settings_repository.dart';
import 'song_repository.dart';

/// A backup snapshot's metadata; the snapshot itself is a JSON file at
/// [filePath] (Entity-Diagrams-UML.md BACKUP, Screens.md #13).
class BackupEntry {
  const BackupEntry({
    required this.id,
    required this.createdAt,
    required this.filePath,
  });

  factory BackupEntry.fromRow(BackupRow row) {
    return BackupEntry(
      id: row.id,
      createdAt: row.createdAt,
      filePath: row.filePath,
    );
  }

  final String id;
  final DateTime createdAt;
  final String filePath;
}

/// Backs up and restores playlists, liked songs, mood tags, and settings
/// (SRS F-5.1/F-5.2) as a self-contained JSON file.
///
/// Songs and playlist entries are matched by file path on restore, not by
/// the device media-store ID cached in [Songs] — that ID isn't stable
/// across a fresh device scan or reinstall, while the file path usually is.
/// Entries whose file path no longer exists in the library are skipped
/// rather than failing the whole restore, consistent with this app's
/// missing-file philosophy (SRS F-5.3).
class BackupRepository {
  BackupRepository({
    required this._database,
    required this._songRepository,
    required this._playlistRepository,
    required this._settingsRepository,
  });

  final AppDatabase _database;
  final SongRepository _songRepository;
  final PlaylistRepository _playlistRepository;
  final SettingsRepository _settingsRepository;
  static const _uuid = Uuid();

  Stream<List<BackupEntry>> watchBackups() {
    final query = _database.select(_database.backups)
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return query.watch().map(
      (rows) => rows.map(BackupEntry.fromRow).toList(growable: false),
    );
  }

  Future<BackupEntry> createBackup() async {
    final settings = await _settingsRepository.currentSettings();
    final taggedSongs = await _songRepository.taggedOrLikedSongs();
    final playlists = await _playlistRepository.allManualPlaylistsWithSongs();

    final data = {
      'version': 1,
      'settings': {
        'adaptiveDarkModeEnabled': settings.adaptiveDarkModeEnabled,
        'manualThemeOverride': settings.manualThemeOverride?.name,
        'themeSeedColorHex': settings.themeSeedColorHex,
        'visualizerColorHex': settings.visualizerColorHex,
        'crossfadeEnabled': settings.crossfadeEnabled,
        'crossfadeDurationMs': settings.crossfadeDuration.inMilliseconds,
      },
      'songs': [
        for (final song in taggedSongs)
          {
            'filePath': song.filePath,
            'isLiked': song.isLiked,
            'moodTagId': song.moodTagId,
          },
      ],
      'playlists': [
        for (final entry in playlists)
          {
            'name': entry.playlist.name,
            'songFilePaths': [for (final song in entry.songs) song.filePath],
          },
      ],
    };

    final backupsDir = await _backupsDirectory();
    final id = _uuid.v4();
    final createdAt = DateTime.now();
    final fileName =
        'zivybb_backup_${createdAt.toIso8601String().replaceAll(':', '-')}.json';
    final file = File(p.join(backupsDir.path, fileName));
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    await _database
        .into(_database.backups)
        .insert(
          BackupsCompanion.insert(
            id: id,
            createdAt: createdAt,
            filePath: file.path,
          ),
        );

    return BackupEntry(id: id, createdAt: createdAt, filePath: file.path);
  }

  /// Restores playlists, liked songs, mood tags, and settings from
  /// [backupId]. Doesn't touch auto-generated mood playlists directly —
  /// callers should regenerate those afterward, since restored mood tags
  /// feed into them.
  Future<void> restoreBackup(String backupId) async {
    final row = await (_database.select(
      _database.backups,
    )..where((t) => t.id.equals(backupId))).getSingle();

    final file = File(row.filePath);
    if (!await file.exists()) {
      throw StateError('Backup file not found: ${row.filePath}');
    }
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    final settingsJson = data['settings'] as Map<String, dynamic>?;
    if (settingsJson != null) {
      await _settingsRepository.setAdaptiveDarkModeEnabled(
        settingsJson['adaptiveDarkModeEnabled'] as bool? ?? true,
      );
      final overrideName = settingsJson['manualThemeOverride'] as String?;
      await _settingsRepository.setManualThemeOverride(
        overrideName == null ? null : ThemeOverride.values.byName(overrideName),
      );
      await _settingsRepository.setThemeSeedColor(
        settingsJson['themeSeedColorHex'] as String? ?? '#673AB7',
      );
      await _settingsRepository.setVisualizerColor(
        settingsJson['visualizerColorHex'] as String? ?? '#673AB7',
      );
      await _settingsRepository.setCrossfadeEnabled(
        settingsJson['crossfadeEnabled'] as bool? ?? false,
      );
      await _settingsRepository.setCrossfadeDuration(
        Duration(
          milliseconds: settingsJson['crossfadeDurationMs'] as int? ?? 3000,
        ),
      );
    }

    final currentSongs = await _songRepository.allSongs();
    final byFilePath = {for (final song in currentSongs) song.filePath: song};

    for (final entry in (data['songs'] as List?) ?? const []) {
      final map = entry as Map<String, dynamic>;
      final match = byFilePath[map['filePath'] as String?];
      if (match == null) continue;
      await _songRepository.setLiked(
        match.id,
        map['isLiked'] as bool? ?? false,
      );
      await _songRepository.setMoodTag(match.id, map['moodTagId'] as String?);
    }

    for (final entry in (data['playlists'] as List?) ?? const []) {
      final map = entry as Map<String, dynamic>;
      final playlist = await _playlistRepository.createPlaylist(
        map['name'] as String? ?? 'Restored playlist',
      );
      final filePaths =
          (map['songFilePaths'] as List?)?.cast<String>() ?? const [];
      for (final filePath in filePaths) {
        final match = byFilePath[filePath];
        if (match != null) {
          await _playlistRepository.addSong(playlist.id, match.id);
        }
      }
    }
  }

  Future<void> deleteBackup(String backupId) async {
    final row = await (_database.select(
      _database.backups,
    )..where((t) => t.id.equals(backupId))).getSingleOrNull();
    if (row == null) return;

    final file = File(row.filePath);
    if (await file.exists()) {
      await file.delete();
    }
    await (_database.delete(
      _database.backups,
    )..where((t) => t.id.equals(backupId))).go();
  }

  Future<Directory> _backupsDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final backupsDir = Directory(p.join(documentsDir.path, 'backups'));
    await backupsDir.create(recursive: true);
    return backupsDir;
  }
}

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepository(
    database: ref.watch(appDatabaseProvider),
    songRepository: ref.watch(songRepositoryProvider),
    playlistRepository: ref.watch(playlistRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
});

final backupsStreamProvider = StreamProvider<List<BackupEntry>>((ref) {
  return ref.watch(backupRepositoryProvider).watchBackups();
});
