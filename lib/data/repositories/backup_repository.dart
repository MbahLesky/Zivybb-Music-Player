import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../datasources/app_database.dart';
import '../models/app_settings.dart';
import '../models/equalizer_preset.dart';
import '../models/vibe_tag.dart';
import 'equalizer_preset_repository.dart';
import 'playlist_repository.dart';
import 'settings_repository.dart';
import 'song_repository.dart';
import 'vibe_tag_repository.dart';

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

/// Backs up and restores playlists, liked songs, vibes, and settings
/// (SRS F-5.1/F-5.2) as a self-contained JSON file.
///
/// Songs and playlist entries are matched by file path on restore, not by
/// the device media-store ID cached in [Songs] — that ID isn't stable
/// across a fresh device scan or reinstall, while the file path usually is.
/// Entries whose file path no longer exists in the library are skipped
/// rather than failing the whole restore, consistent with this app's
/// missing-file philosophy (SRS F-5.3).
///
/// Format version 4 carries every stored setting rather than the six theme
/// and crossfade ones earlier versions kept, plus the user's hand-tuned
/// equalizer curve. Format version 3 adds the vibe folders and each vibe's
/// place in them. Version 2 stores a list of vibes per song plus the vibe
/// definitions themselves; version 1 (a single `moodTagId` per song, with no
/// definitions) is still restorable — see [restoreBackup].
///
/// Older files need no special handling on the settings side: every version
/// is read by one path that defaults whatever the file leaves out, so a v3
/// backup restores its six settings and starts the rest fresh.
class BackupRepository {
  BackupRepository({
    required this._database,
    required this._songRepository,
    required this._playlistRepository,
    required this._settingsRepository,
    required this._vibeTagRepository,
    required this._equalizerPresetRepository,
  });

  final AppDatabase _database;
  final SongRepository _songRepository;
  final PlaylistRepository _playlistRepository;
  final SettingsRepository _settingsRepository;
  final VibeTagRepository _vibeTagRepository;
  final EqualizerPresetRepository _equalizerPresetRepository;
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
    final vibeCategories = await _vibeTagRepository.allVibeCategories();
    final vibeTags = await _vibeTagRepository.allVibeTags();
    final vibeIdsBySong = await _vibeTagRepository.allSongVibeIds();
    final taggedSongs = await _songRepository.taggedOrLikedSongs(
      vibeIdsBySong.keys.toSet(),
    );
    final playlists = await _playlistRepository.allManualPlaylistsWithSongs();
    final customCurve = _customCurveOf(
      await _equalizerPresetRepository.allPresets(),
    );

    final data = {
      'version': 4,
      // Every column of the settings row. `AppSettings.themeStyleName` is
      // deliberately absent: it has no column behind it, so there is nothing
      // stored for a backup to carry.
      'settings': {
        'adaptiveDarkModeEnabled': settings.adaptiveDarkModeEnabled,
        'manualThemeOverride': settings.manualThemeOverride?.name,
        'themeSeedColorHex': settings.themeSeedColorHex,
        'visualizerColorHex': settings.visualizerColorHex,
        'crossfadeEnabled': settings.crossfadeEnabled,
        'crossfadeDurationMs': settings.crossfadeDuration.inMilliseconds,
        'currentEqualizerPresetId': settings.currentEqualizerPresetId,
        'visualizerStyle': settings.visualizerStyle.name,
        'showAlbumArtInMiniPlayer': settings.showAlbumArtInMiniPlayer,
        'showVisualizerInMiniPlayer': settings.showVisualizerInMiniPlayer,
        'showAlbumArtInNowPlaying': settings.showAlbumArtInNowPlaying,
        'visualizerPlacement': settings.visualizerPlacement.name,
        'visualizerAsArtworkFallback': settings.visualizerAsArtworkFallback,
        'visualizerSensitivity': settings.visualizerTuning.sensitivity,
        'visualizerContrast': settings.visualizerTuning.contrast,
        'visualizerFloor': settings.visualizerTuning.floor,
        'visualizerResponsiveness': settings.visualizerTuning.responsiveness,
        'visualizerBarCount': settings.visualizerTuning.barCount,
        'seekStepSeconds': settings.seekStep.inSeconds,
        'includeVideos': settings.includeVideos,
        'realVisualizerEnabled': settings.realVisualizerEnabled,
      },
      'equalizer': {
        // Only the hand-tuned curve. The built-in presets are defined in
        // code and seeded on launch, so carrying them would let an old
        // backup pin a superseded curve over the current one.
        'customBandGains': ?customCurve,
      },
      'vibeCategories': [
        for (final category in vibeCategories)
          {
            'id': category.id,
            'name': category.name,
            'colorHex': category.colorHex,
          },
      ],
      'vibeTags': [
        for (final tag in vibeTags)
          {
            'id': tag.id,
            'label': tag.label,
            'colorHex': tag.colorHex,
            'categoryId': tag.categoryId,
          },
      ],
      'songs': [
        for (final song in taggedSongs)
          {
            'filePath': song.filePath,
            'isLiked': song.isLiked,
            'vibeTagIds': vibeIdsBySong[song.id] ?? const <String>[],
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

  /// Restores playlists, liked songs, vibes, and settings from [backupId].
  /// Doesn't touch auto-generated vibe playlists directly — callers should
  /// regenerate those afterward, since restored vibes feed into them.
  ///
  /// Reads both format versions: version 1's single `moodTagId` per song
  /// becomes that song's one vibe.
  Future<void> restoreBackup(String backupId) async {
    final row = await (_database.select(
      _database.backups,
    )..where((t) => t.id.equals(backupId))).getSingle();

    final file = File(row.filePath);
    if (!await file.exists()) {
      throw StateError('Backup file not found: ${row.filePath}');
    }
    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    // The curve before the settings that may name it: the selected preset is
    // a foreign key, so the `custom` row has to exist before a settings write
    // can point at it.
    final backedUpCurve =
        ((data['equalizer'] as Map<String, dynamic>?)?['customBandGains']
                as List?)
            ?.cast<num>();
    if (backedUpCurve != null) {
      await _equalizerPresetRepository.upsertPreset(
        EqualizerPreset(
          id: customEqualizerPresetId,
          // Only used if this install has no `custom` row yet; an existing
          // one keeps the name the app itself seeded.
          name: 'Custom',
          bandGains: _normalizedBandGains(backedUpCurve),
        ),
      );
    }

    final settingsJson = data['settings'] as Map<String, dynamic>?;
    if (settingsJson != null) {
      await _settingsRepository.replaceAll(
        _settingsFrom(
          settingsJson,
          current: await _settingsRepository.currentSettings(),
          knownPresetIds: {
            for (final preset in await _equalizerPresetRepository.allPresets())
              preset.id,
          },
        ),
      );
    }

    // Folders before the vibes that sit in them, and both before the per-song
    // assignments, so nothing is restored pointing at something that doesn't
    // exist yet. Existing rows win throughout, so a restore never overwrites
    // names or colors the user has since changed. Version 2 and earlier
    // backups have no folders, and their vibes restore uncategorised.
    final backedUpCategories = (data['vibeCategories'] as List?) ?? const [];
    for (final (index, entry) in backedUpCategories.indexed) {
      final map = entry as Map<String, dynamic>;
      final id = map['id'] as String?;
      if (id == null) continue;
      await _vibeTagRepository.upsertVibeCategory(
        VibeCategory(
          id: id,
          name: map['name'] as String? ?? id,
          colorHex: map['colorHex'] as String? ?? '#7E57C2',
        ),
        sortOrder: index,
      );
    }

    final knownCategoryIds = {
      for (final category in await _vibeTagRepository.allVibeCategories())
        category.id,
    };
    final backedUpTags = (data['vibeTags'] as List?) ?? const [];
    for (final (index, entry) in backedUpTags.indexed) {
      final map = entry as Map<String, dynamic>;
      final id = map['id'] as String?;
      if (id == null) continue;
      final categoryId = map['categoryId'] as String?;
      await _vibeTagRepository.upsertVibeTag(
        VibeTag(
          id: id,
          label: map['label'] as String? ?? id,
          colorHex: map['colorHex'] as String? ?? '#FF7043',
          // A folder the backup names but that no longer exists leaves the
          // vibe uncategorised rather than dangling.
          categoryId: knownCategoryIds.contains(categoryId) ? categoryId : null,
        ),
        sortOrder: index,
      );
    }

    final knownVibeIds = {
      for (final tag in await _vibeTagRepository.allVibeTags()) tag.id,
    };
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

      final vibeIds =
          (map['vibeTagIds'] as List?)?.cast<String>() ??
          // Version 1 fallback: one mood per song.
          [?map['moodTagId'] as String?];
      await _vibeTagRepository.setSongVibes(match.id, [
        for (final id in vibeIds)
          if (knownVibeIds.contains(id)) id,
      ]);
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

  /// Reads a backup's settings block over the top of [current].
  ///
  /// One path reads every format version, and anything the file doesn't
  /// carry keeps the value it has now. That's what lets a pre-v4 backup —
  /// which stored only the six theme and crossfade settings — restore those
  /// six without resetting the fifteen it never knew about, exactly as it
  /// behaved before the format grew.
  static AppSettings _settingsFrom(
    Map<String, dynamic> json, {
    required AppSettings current,
    required Set<String> knownPresetIds,
  }) {
    final tuning = current.visualizerTuning;
    // Both of these are nullable settings, so an absent key and a stored
    // null mean different things: keep what's there, versus clear it.
    final presetId = json.containsKey('currentEqualizerPresetId')
        ? json['currentEqualizerPresetId'] as String?
        : current.currentEqualizerPresetId;
    final themeOverride = json.containsKey('manualThemeOverride')
        ? _enumByName(ThemeOverride.values, json['manualThemeOverride'])
        : current.manualThemeOverride;

    return AppSettings(
      adaptiveDarkModeEnabled:
          json['adaptiveDarkModeEnabled'] as bool? ??
          current.adaptiveDarkModeEnabled,
      manualThemeOverride: themeOverride,
      themeSeedColorHex:
          json['themeSeedColorHex'] as String? ?? current.themeSeedColorHex,
      visualizerColorHex:
          json['visualizerColorHex'] as String? ?? current.visualizerColorHex,
      crossfadeEnabled:
          json['crossfadeEnabled'] as bool? ?? current.crossfadeEnabled,
      crossfadeDuration: Duration(
        milliseconds:
            json['crossfadeDurationMs'] as int? ??
            current.crossfadeDuration.inMilliseconds,
      ),
      // A preset the backup names but that this install doesn't have leaves
      // the selection empty rather than failing the column's foreign key.
      currentEqualizerPresetId: knownPresetIds.contains(presetId)
          ? presetId
          : null,
      visualizerStyle:
          _enumByName(VisualizerStyle.values, json['visualizerStyle']) ??
          current.visualizerStyle,
      showAlbumArtInMiniPlayer:
          json['showAlbumArtInMiniPlayer'] as bool? ??
          current.showAlbumArtInMiniPlayer,
      showVisualizerInMiniPlayer:
          json['showVisualizerInMiniPlayer'] as bool? ??
          current.showVisualizerInMiniPlayer,
      showAlbumArtInNowPlaying:
          json['showAlbumArtInNowPlaying'] as bool? ??
          current.showAlbumArtInNowPlaying,
      visualizerPlacement:
          _enumByName(
            VisualizerPlacement.values,
            json['visualizerPlacement'],
          ) ??
          current.visualizerPlacement,
      visualizerAsArtworkFallback:
          json['visualizerAsArtworkFallback'] as bool? ??
          current.visualizerAsArtworkFallback,
      // Left unclamped here; `SettingsRepository.replaceAll` clamps on the
      // way to the row, as reading one back does on the way out.
      visualizerTuning: VisualizerTuning(
        sensitivity:
            (json['visualizerSensitivity'] as num?)?.toDouble() ??
            tuning.sensitivity,
        contrast:
            (json['visualizerContrast'] as num?)?.toDouble() ?? tuning.contrast,
        floor: (json['visualizerFloor'] as num?)?.toDouble() ?? tuning.floor,
        responsiveness:
            (json['visualizerResponsiveness'] as num?)?.toDouble() ??
            tuning.responsiveness,
        barCount: json['visualizerBarCount'] as int? ?? tuning.barCount,
      ),
      seekStep: Duration(
        seconds: json['seekStepSeconds'] as int? ?? current.seekStep.inSeconds,
      ),
      includeVideos: json['includeVideos'] as bool? ?? current.includeVideos,
      realVisualizerEnabled:
          json['realVisualizerEnabled'] as bool? ??
          current.realVisualizerEnabled,
    );
  }

  /// Looks a value up by [name], returning null for anything the enum
  /// doesn't have.
  ///
  /// A backup is plain JSON sitting on disk: it can name a value written by
  /// a newer build, or one a user hand-edited into nonsense — and it need
  /// not even be a string. `values.byName` throws on all of those, taking
  /// the whole restore with it.
  static T? _enumByName<T extends Enum>(List<T> values, Object? name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }

  static List<double>? _customCurveOf(List<EqualizerPreset> presets) {
    for (final preset in presets) {
      if (preset.id == customEqualizerPresetId) return preset.bandGains;
    }
    return null;
  }

  /// Forces a backed-up curve into the shape the equalizer screen indexes
  /// into: one gain per band, each inside the sliders' range. A file written
  /// by a build with a different band count would otherwise throw a
  /// [RangeError] the first time a slider moved.
  static List<double> _normalizedBandGains(List<num> gains) {
    return [
      for (var band = 0; band < equalizerBandLabels.length; band++)
        _gainAt(gains, band),
    ];
  }

  /// 0 dB for a band the backup doesn't cover, or one whose value isn't a
  /// usable number.
  static double _gainAt(List<num> gains, int band) {
    if (band >= gains.length) return 0;
    final gain = gains[band].toDouble();
    if (!gain.isFinite) return 0;
    return gain.clamp(-equalizerMaxGainDb, equalizerMaxGainDb);
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
    vibeTagRepository: ref.watch(vibeTagRepositoryProvider),
    equalizerPresetRepository: ref.watch(equalizerPresetRepositoryProvider),
  );
});

final backupsStreamProvider = StreamProvider<List<BackupEntry>>((ref) {
  return ref.watch(backupRepositoryProvider).watchBackups();
});
