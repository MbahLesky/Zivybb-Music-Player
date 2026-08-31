import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/models/app_settings.dart';
import 'package:zivybb/data/models/vibe_tag.dart';
import 'package:zivybb/data/repositories/backup_repository.dart';
import 'package:zivybb/data/repositories/equalizer_preset_repository.dart';
import 'package:zivybb/data/repositories/playlist_repository.dart';
import 'package:zivybb/data/repositories/settings_repository.dart';
import 'package:zivybb/data/repositories/song_repository.dart';
import 'package:zivybb/data/repositories/vibe_tag_repository.dart';

import 'support/fake_scanner.dart';

/// Covers the Definition of Done's "backup/restore verified to correctly
/// round-trip playlists, favorites, tags, and settings" (SRS F-5.1/F-5.2).
///
/// Every test drives the real [BackupRepository] against a real JSON file on
/// disk — the format is the thing being verified, so stubbing the file out
/// would test nothing that matters.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory documents;
  late AppDatabase database;
  late BackupRepository backups;
  late SongRepository songs;
  late PlaylistRepository playlists;
  late SettingsRepository settings;
  late VibeTagRepository vibes;
  late EqualizerPresetRepository equalizer;

  // path_provider has no platform implementation under `flutter test`, so
  // point its channel at a real temp directory and let the repository write
  // an actual backup file into it.
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() async {
    documents = await Directory.systemTemp.createTemp('zivybb_backup_test');
    messenger.setMockMethodCallHandler(pathProviderChannel, (call) async {
      return call.method == 'getApplicationDocumentsDirectory'
          ? documents.path
          : null;
    });

    database = AppDatabase.connect(NativeDatabase.memory());
    songs = SongRepository(database: database, scanner: FakeScanner());
    playlists = PlaylistRepository(database: database);
    settings = SettingsRepository(database: database);
    vibes = VibeTagRepository(database: database);
    equalizer = EqualizerPresetRepository(database: database);
    backups = BackupRepository(
      database: database,
      songRepository: songs,
      playlistRepository: playlists,
      settingsRepository: settings,
      vibeTagRepository: vibes,
      equalizerPresetRepository: equalizer,
    );
    // The app seeds these on launch; the settings row's selected-preset
    // column is a foreign key onto them, so nothing here can name one until
    // the rows exist.
    await equalizer.ensureSeeded();
  });

  tearDown(() async {
    messenger.setMockMethodCallHandler(pathProviderChannel, null);
    await database.close();
    if (documents.existsSync()) await documents.delete(recursive: true);
  });

  /// Inserts a song straight into the cache, bypassing the device scan.
  /// [id] and [filePath] are separate because the backup format deliberately
  /// keys on the path, not the media-store id.
  Future<void> insertSong(String id, {String? filePath}) {
    return database
        .into(database.songs)
        .insert(
          SongsCompanion.insert(
            id: id,
            filePath: filePath ?? '/music/$id.mp3',
            title: id,
            artist: 'Artist',
            album: 'Album',
            durationMs: 180000,
          ),
        );
  }

  Future<void> seedLibraryState() async {
    await insertSong('a');
    await insertSong('b');
    await insertSong('c');

    await vibes.upsertVibeCategory(
      const VibeCategory(id: 'mood', name: 'Mood', colorHex: '#7E57C2'),
      sortOrder: 0,
    );
    await vibes.upsertVibeTag(
      const VibeTag(
        id: 'chill',
        label: 'Chill',
        colorHex: '#4FC3F7',
        categoryId: 'mood',
      ),
      sortOrder: 0,
    );
    await vibes.setSongVibes('a', ['chill']);
    await songs.setLiked('b', true);

    final playlist = await playlists.createPlaylist('Road trip');
    await playlists.addSong(playlist.id, 'a');
    await playlists.addSong(playlist.id, 'c');

    await settings.setThemeSeedColor('#FF5722');
    await settings.setVisualizerColor('#00BCD4');
    await settings.setCrossfadeEnabled(true);
    await settings.setCrossfadeDuration(const Duration(seconds: 5));
    await settings.setAdaptiveDarkModeEnabled(false);
    await settings.setManualThemeOverride(ThemeOverride.dark);
  }

  /// Undoes everything [seedLibraryState] set, leaving the songs themselves
  /// in place — the state a restore is supposed to bring back.
  Future<void> wipeUserState() async {
    await songs.setLiked('b', false);
    await vibes.setSongVibes('a', const []);
    await database.delete(database.playlists).go();
    await settings.setThemeSeedColor('#673AB7');
    await settings.setVisualizerColor('#673AB7');
    await settings.setCrossfadeEnabled(false);
    await settings.setCrossfadeDuration(const Duration(seconds: 15));
    await settings.setAdaptiveDarkModeEnabled(true);
    await settings.setManualThemeOverride(null);
  }

  Future<List<String>> playlistSongIds(String name) async {
    final all = await playlists.allManualPlaylistsWithSongs();
    final match = all.firstWhere((entry) => entry.playlist.name == name);
    return [for (final song in match.songs) song.id];
  }

  group('createBackup', () {
    test('writes a readable JSON file and records it', () async {
      await seedLibraryState();

      final entry = await backups.createBackup();

      final file = File(entry.filePath);
      expect(file.existsSync(), isTrue);
      final data =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      expect(data['version'], 5);

      final listed = await backups.watchBackups().first;
      expect(listed.map((backup) => backup.id), [entry.id]);
    });

    test('backs up songs by file path rather than media-store id', () async {
      // The ids are what a rescan or reinstall renumbers, so they must not
      // appear in the file at all.
      await seedLibraryState();

      final entry = await backups.createBackup();
      final data =
          jsonDecode(await File(entry.filePath).readAsString())
              as Map<String, dynamic>;

      final backedUpSongs = (data['songs'] as List)
          .cast<Map<String, dynamic>>();
      expect(
        backedUpSongs.map((song) => song['filePath']),
        containsAll(<String>['/music/a.mp3', '/music/b.mp3']),
      );
      expect(backedUpSongs.every((song) => !song.containsKey('id')), isTrue);
    });

    test('leaves out songs that are neither liked nor tagged', () async {
      await seedLibraryState();

      final entry = await backups.createBackup();
      final data =
          jsonDecode(await File(entry.filePath).readAsString())
              as Map<String, dynamic>;

      // 'c' is only a playlist member — carried by the playlist entry, not
      // as a song with state of its own.
      final paths = [
        for (final song in (data['songs'] as List).cast<Map<String, dynamic>>())
          song['filePath'],
      ];
      expect(paths, isNot(contains('/music/c.mp3')));
    });
  });

  group('restoreBackup', () {
    test('round-trips playlists, favorites, vibes, and settings', () async {
      await seedLibraryState();
      final entry = await backups.createBackup();
      await wipeUserState();

      // Guard the guard: the wipe has to have actually removed everything,
      // or the assertions below would pass without a restore happening.
      expect((await songs.allSongs()).where((s) => s.isLiked), isEmpty);
      expect(await playlists.allManualPlaylistsWithSongs(), isEmpty);

      await backups.restoreBackup(entry.id);

      final restored = await songs.allSongs();
      expect(restored.firstWhere((s) => s.id == 'b').isLiked, isTrue);
      expect(await vibes.allSongVibeIds(), {
        'a': ['chill'],
      });
      expect(await playlistSongIds('Road trip'), ['a', 'c']);

      final restoredSettings = await settings.currentSettings();
      expect(restoredSettings.themeSeedColorHex, '#FF5722');
      expect(restoredSettings.visualizerColorHex, '#00BCD4');
      expect(restoredSettings.crossfadeEnabled, isTrue);
      expect(restoredSettings.crossfadeDuration, const Duration(seconds: 5));
      expect(restoredSettings.adaptiveDarkModeEnabled, isFalse);
      expect(restoredSettings.manualThemeOverride, ThemeOverride.dark);
    });

    test('restores the vibe folder each vibe belonged to', () async {
      await seedLibraryState();
      final entry = await backups.createBackup();
      await database.delete(database.vibeTags).go();
      await database.delete(database.vibeCategories).go();

      await backups.restoreBackup(entry.id);

      final categories = await vibes.allVibeCategories();
      expect(categories.map((category) => category.name), ['Mood']);
      expect(
        (await vibes.allVibeTags()).single.categoryId,
        'mood',
        reason: 'a restored vibe should land back in its folder',
      );
    });

    test('re-attaches state by file path after the ids change', () async {
      // What a reinstall or a fresh device scan actually looks like: same
      // files on disk, entirely new media-store ids.
      await seedLibraryState();
      final entry = await backups.createBackup();

      await database.delete(database.playlists).go();
      await database.delete(database.songVibes).go();
      await database.delete(database.songs).go();
      await insertSong('900', filePath: '/music/a.mp3');
      await insertSong('901', filePath: '/music/b.mp3');
      await insertSong('902', filePath: '/music/c.mp3');

      await backups.restoreBackup(entry.id);

      final restored = await songs.allSongs();
      expect(restored.firstWhere((s) => s.id == '901').isLiked, isTrue);
      expect(await vibes.allSongVibeIds(), {
        '900': ['chill'],
      });
      expect(await playlistSongIds('Road trip'), ['900', '902']);
    });

    test('skips entries whose file is no longer in the library', () async {
      await seedLibraryState();
      final entry = await backups.createBackup();

      // 'c' has gone from the device; the rest of the restore must still
      // land rather than the whole thing failing (SRS F-5.3).
      await database.delete(database.playlists).go();
      await (database.delete(
        database.songs,
      )..where((t) => t.id.equals('c'))).go();

      await backups.restoreBackup(entry.id);

      expect(await playlistSongIds('Road trip'), ['a']);
    });

    test('keeps a vibe the user has since renamed', () async {
      await seedLibraryState();
      final entry = await backups.createBackup();
      await vibes.renameVibeTag('chill', 'Mellow');
      // Cleared so the restore has something to actually do — otherwise this
      // would pass just as happily against a restore that did nothing.
      await vibes.setSongVibes('a', const []);

      await backups.restoreBackup(entry.id);

      expect(await vibes.allSongVibeIds(), {
        'a': ['chill'],
      });
      expect(
        (await vibes.allVibeTags()).single.label,
        'Mellow',
        reason: 'existing rows win, so a restore never undoes a later edit',
      );
    });

    test('reads a version 1 backup, whose songs carry a single mood', () async {
      await insertSong('a');
      await vibes.upsertVibeTag(
        const VibeTag(id: 'chill', label: 'Chill', colorHex: '#4FC3F7'),
        sortOrder: 0,
      );
      final legacy = await _writeLegacyBackup(database, documents);

      await backups.restoreBackup(legacy);

      expect(await vibes.allSongVibeIds(), {
        'a': ['chill'],
      });
    });

    test('fails loudly when the backup file has been deleted', () async {
      await seedLibraryState();
      final entry = await backups.createBackup();
      await File(entry.filePath).delete();

      expect(() => backups.restoreBackup(entry.id), throwsA(isA<StateError>()));
    });
  });

  group('settings and the equalizer curve', () {
    /// The settings formats before version 4 never carried, each set to
    /// something plainly non-default so a restore that skipped one shows up
    /// as a failure rather than passing on the default.
    Future<void> seedNewerSettings() async {
      await settings.setEqualizerPreset(customEqualizerPresetId);
      await settings.setVisualizerStyle(VisualizerStyle.ribbon);
      await settings.setShowAlbumArtInMiniPlayer(false);
      await settings.setShowVisualizerInMiniPlayer(true);
      await settings.setShowAlbumArtInNowPlaying(false);
      await settings.setVisualizerPlacement(VisualizerPlacement.seekBar);
      await settings.setVisualizerAsArtworkFallback(true);
      await settings.setVisualizerTuning(
        VisualizerResponsePreset.punchy.tuning,
      );
      await settings.setSeekStep(const Duration(seconds: 30));
      await settings.setIncludeVideos(true);
      await settings.setRealVisualizerEnabled(true);
    }

    /// Puts all of those back to their defaults one field at a time.
    ///
    /// Deliberately not `replaceAll` — that's the write the restore itself
    /// goes through, and a column it silently skipped would then be missed
    /// by the wipe and the restore alike, leaving the assertions below to
    /// pass on a value that was never touched.
    Future<void> resetNewerSettings() async {
      const defaults = AppSettings();
      await settings.setEqualizerPreset(defaults.currentEqualizerPresetId);
      await settings.setVisualizerStyle(defaults.visualizerStyle);
      await settings.setShowAlbumArtInMiniPlayer(
        defaults.showAlbumArtInMiniPlayer,
      );
      await settings.setShowVisualizerInMiniPlayer(
        defaults.showVisualizerInMiniPlayer,
      );
      await settings.setShowAlbumArtInNowPlaying(
        defaults.showAlbumArtInNowPlaying,
      );
      await settings.setVisualizerPlacement(defaults.visualizerPlacement);
      await settings.setVisualizerAsArtworkFallback(
        defaults.visualizerAsArtworkFallback,
      );
      await settings.setVisualizerTuning(defaults.visualizerTuning);
      await settings.setSeekStep(defaults.seekStep);
      await settings.setIncludeVideos(defaults.includeVideos);
      await settings.setRealVisualizerEnabled(defaults.realVisualizerEnabled);
    }

    Future<List<double>> customBandGains() async {
      final presets = await equalizer.allPresets();
      return presets
          .firstWhere((preset) => preset.id == customEqualizerPresetId)
          .bandGains;
    }

    test('round-trips every setting the older formats left out', () async {
      await seedNewerSettings();
      final entry = await backups.createBackup();

      await resetNewerSettings();
      // Guard the guard, as the restore tests above do.
      final wiped = await settings.currentSettings();
      expect(wiped.includeVideos, isFalse);
      expect(wiped.currentEqualizerPresetId, isNull);
      expect(wiped.visualizerPlacement, VisualizerPlacement.belowControls);

      await backups.restoreBackup(entry.id);

      final restored = await settings.currentSettings();
      expect(restored.currentEqualizerPresetId, customEqualizerPresetId);
      expect(restored.visualizerStyle, VisualizerStyle.ribbon);
      expect(restored.showAlbumArtInMiniPlayer, isFalse);
      expect(restored.showVisualizerInMiniPlayer, isTrue);
      expect(restored.showAlbumArtInNowPlaying, isFalse);
      expect(restored.visualizerPlacement, VisualizerPlacement.seekBar);
      expect(restored.visualizerAsArtworkFallback, isTrue);
      expect(restored.visualizerTuning, VisualizerResponsePreset.punchy.tuning);
      expect(restored.seekStep, const Duration(seconds: 30));
      expect(restored.includeVideos, isTrue);
      expect(restored.realVisualizerEnabled, isTrue);
    });

    test('round-trips the hand-tuned equalizer curve', () async {
      await equalizer.updateBandGains(customEqualizerPresetId, [
        6,
        -3,
        0,
        2,
        -1,
      ]);
      final entry = await backups.createBackup();
      await equalizer.updateBandGains(
        customEqualizerPresetId,
        List<double>.filled(equalizerBandLabels.length, 0),
      );

      await backups.restoreBackup(entry.id);

      expect(await customBandGains(), [6, -3, 0, 2, -1]);
    });

    test('leaves the built-in presets to the code that defines them', () async {
      final entry = await backups.createBackup();
      // As if a later app version had retuned a built-in curve.
      await equalizer.updateBandGains('bass_boost', [9, 9, 9, 9, 9]);

      await backups.restoreBackup(entry.id);

      final presets = await equalizer.allPresets();
      final bassBoost = presets.firstWhere((p) => p.id == 'bass_boost');
      expect(bassBoost.bandGains, [9, 9, 9, 9, 9]);
    });

    test('leaves settings a version 3 backup predates untouched', () async {
      await settings.setIncludeVideos(true);
      await settings.setSeekStep(const Duration(seconds: 30));
      final legacy = await _writeBackupFile(
        database,
        documents,
        id: 'v3',
        data: {
          'version': 3,
          'settings': {
            'adaptiveDarkModeEnabled': false,
            'themeSeedColorHex': '#FF5722',
            'crossfadeEnabled': true,
            'crossfadeDurationMs': 5000,
          },
        },
      );

      await backups.restoreBackup(legacy);

      final restored = await settings.currentSettings();
      // What the file carries is restored...
      expect(restored.adaptiveDarkModeEnabled, isFalse);
      expect(restored.themeSeedColorHex, '#FF5722');
      expect(restored.crossfadeEnabled, isTrue);
      expect(restored.crossfadeDuration, const Duration(seconds: 5));
      // ...and what it predates keeps the value it already had, rather than
      // being reset by a format that never knew about it.
      expect(restored.includeVideos, isTrue);
      expect(restored.seekStep, const Duration(seconds: 30));
    });

    test('clears a selected preset this install does not have', () async {
      final orphaned = await _writeBackupFile(
        database,
        documents,
        id: 'gone',
        data: {
          'version': 4,
          'settings': {'currentEqualizerPresetId': 'preset_from_another_build'},
        },
      );

      // The column is a foreign key, so the alternative to dropping it is
      // the whole restore failing.
      await backups.restoreBackup(orphaned);

      expect((await settings.currentSettings()).currentEqualizerPresetId, null);
    });

    test('pads and clamps a curve whose bands do not line up', () async {
      final odd = await _writeBackupFile(
        database,
        documents,
        id: 'odd',
        data: {
          'version': 4,
          'equalizer': {
            'customBandGains': [99, -99, 3],
          },
        },
      );

      await backups.restoreBackup(odd);

      expect(await customBandGains(), [
        equalizerMaxGainDb,
        -equalizerMaxGainDb,
        3,
        // Bands the file never covered, rather than a short list the
        // equalizer sliders would index straight off the end of.
        0,
        0,
      ]);
    });
  });

  group('deleteBackup', () {
    test('removes both the file and the record', () async {
      await seedLibraryState();
      final entry = await backups.createBackup();

      await backups.deleteBackup(entry.id);

      expect(File(entry.filePath).existsSync(), isFalse);
      expect(await backups.watchBackups().first, isEmpty);
    });

    test('is a no-op for a backup that is already gone', () async {
      await backups.deleteBackup('never-existed');
      expect(await backups.watchBackups().first, isEmpty);
    });
  });
}

/// Writes a version 1 backup file (one `moodTagId` per song, no vibe
/// definitions) and registers it, returning its id.
Future<String> _writeLegacyBackup(AppDatabase database, Directory documents) {
  return _writeBackupFile(
    database,
    documents,
    id: 'legacy',
    data: {
      'version': 1,
      'songs': [
        {'filePath': '/music/a.mp3', 'isLiked': false, 'moodTagId': 'chill'},
      ],
    },
  );
}

/// Writes [data] as a backup file and registers it, returning its id.
///
/// Hand-building the JSON is the point: these cover files this build can no
/// longer produce — an older format version, or a value from another install
/// — which [BackupRepository.createBackup] would never write.
Future<String> _writeBackupFile(
  AppDatabase database,
  Directory documents, {
  required String id,
  required Map<String, Object?> data,
}) async {
  final directory = Directory('${documents.path}/backups')
    ..createSync(recursive: true);
  final file = File('${directory.path}/$id.json');
  await file.writeAsString(jsonEncode(data));

  await database
      .into(database.backups)
      .insert(
        BackupsCompanion.insert(
          id: id,
          createdAt: DateTime(2026),
          filePath: file.path,
        ),
      );
  return id;
}
