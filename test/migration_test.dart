import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zivybb/data/datasources/app_database.dart';
import 'package:zivybb/data/repositories/vibe_tag_repository.dart';

/// Builds the v8 (pre-Vibe) schema — the shape shipped on-device before the
/// Mood → Vibe rename — so the v9 upgrade can be exercised against real
/// data rather than a freshly created database.
const _v8Schema = [
  '''
  CREATE TABLE mood_tags (
    id TEXT NOT NULL PRIMARY KEY,
    label TEXT NOT NULL,
    color_hex TEXT NOT NULL,
    sort_order INTEGER NOT NULL DEFAULT 0
  )''',
  '''
  CREATE TABLE songs (
    id TEXT NOT NULL PRIMARY KEY,
    file_path TEXT NOT NULL,
    title TEXT NOT NULL,
    artist TEXT NOT NULL,
    album TEXT NOT NULL,
    duration_ms INTEGER NOT NULL,
    mood_tag_id TEXT REFERENCES mood_tags (id) ON DELETE SET NULL,
    is_liked INTEGER NOT NULL DEFAULT 0 CHECK (is_liked IN (0, 1)),
    is_missing INTEGER NOT NULL DEFAULT 0 CHECK (is_missing IN (0, 1)),
    play_count INTEGER NOT NULL DEFAULT 0,
    last_played_at INTEGER
  )''',
  '''
  CREATE TABLE playlists (
    id TEXT NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    is_auto_generated INTEGER NOT NULL DEFAULT 0
      CHECK (is_auto_generated IN (0, 1)),
    source_mood_tag_id TEXT REFERENCES mood_tags (id) ON DELETE SET NULL,
    created_at INTEGER NOT NULL,
    cover_image_path TEXT
  )''',
  '''
  CREATE TABLE playlist_songs (
    playlist_id TEXT NOT NULL REFERENCES playlists (id) ON DELETE CASCADE,
    song_id TEXT NOT NULL REFERENCES songs (id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    PRIMARY KEY (playlist_id, song_id)
  )''',
  '''
  CREATE TABLE equalizer_presets (
    id TEXT NOT NULL PRIMARY KEY,
    name TEXT NOT NULL,
    band_levels_json TEXT NOT NULL
  )''',
  '''
  CREATE TABLE backups (
    id TEXT NOT NULL PRIMARY KEY,
    created_at INTEGER NOT NULL,
    file_path TEXT NOT NULL
  )''',
  '''
  CREATE TABLE settings (
    id TEXT NOT NULL PRIMARY KEY,
    adaptive_dark_mode_enabled INTEGER NOT NULL DEFAULT 1
      CHECK (adaptive_dark_mode_enabled IN (0, 1)),
    manual_theme_override TEXT,
    theme_seed_color_hex TEXT NOT NULL DEFAULT '#673AB7',
    visualizer_color_hex TEXT NOT NULL DEFAULT '#673AB7',
    crossfade_enabled INTEGER NOT NULL DEFAULT 0
      CHECK (crossfade_enabled IN (0, 1)),
    crossfade_duration_ms INTEGER NOT NULL DEFAULT 3000,
    current_equalizer_preset_id TEXT
      REFERENCES equalizer_presets (id) ON DELETE SET NULL,
    visualizer_style TEXT NOT NULL DEFAULT 'bars',
    show_album_art_in_mini_player INTEGER NOT NULL DEFAULT 1
      CHECK (show_album_art_in_mini_player IN (0, 1)),
    show_visualizer_in_mini_player INTEGER NOT NULL DEFAULT 0
      CHECK (show_visualizer_in_mini_player IN (0, 1)),
    show_album_art_in_now_playing INTEGER NOT NULL DEFAULT 1
      CHECK (show_album_art_in_now_playing IN (0, 1)),
    show_visualizer_in_now_playing INTEGER NOT NULL DEFAULT 1
      CHECK (show_visualizer_in_now_playing IN (0, 1)),
    seek_step_seconds INTEGER NOT NULL DEFAULT 10
  )''',
  // The visualizer is switched off on Now Playing here, so the v13 step that
  // replaces that boolean with `visualizer_placement` has something other
  // than the default to carry over.
  'INSERT INTO settings (id, crossfade_enabled, seek_step_seconds, '
      'show_visualizer_in_now_playing) '
      "VALUES ('default', 1, 15, 0)",
  "INSERT INTO mood_tags VALUES ('chill', 'Chill', '#4FC3F7', 0)",
  "INSERT INTO mood_tags VALUES ('happy', 'Happy', '#FFCA28', 1)",
  "INSERT INTO songs VALUES ('1', '/music/a.mp3', 'A', 'Artist', 'Album', "
      "1000, 'chill', 1, 0, 3, NULL)",
  "INSERT INTO songs VALUES ('2', '/music/b.mp3', 'B', 'Artist', 'Album', "
      '2000, NULL, 0, 0, 0, NULL)',
  // A dangling tag id: possible historically, since foreign keys are not
  // enforced on this connection. Must not migrate into song_vibes.
  "INSERT INTO songs VALUES ('3', '/music/c.mp3', 'C', 'Artist', 'Album', "
      "3000, 'deleted-tag', 0, 0, 0, NULL)",
  "INSERT INTO playlists VALUES ('p1', 'Chill Mix', 1, 'chill', 0, NULL)",
];

void main() {
  test(
    'v8 → current migrates moods to vibes, preserving songs and tags',
    () async {
      final database = AppDatabase.connect(
        NativeDatabase.memory(
          setup: (rawDb) {
            for (final statement in _v8Schema) {
              rawDb.execute(statement);
            }
            rawDb.execute('PRAGMA user_version = 8');
          },
        ),
      );
      addTearDown(database.close);

      // Any query triggers the migration.
      final vibes = await database.select(database.vibeTags).get();
      expect(
        vibes.map((v) => v.id),
        containsAll(<String>['chill', 'happy']),
        reason: 'existing mood tags should survive the table rename',
      );
      expect(
        vibes.firstWhere((v) => v.id == 'chill').label,
        'Chill',
        reason: 'labels and colors should carry over untouched',
      );

      final songVibes = await database.select(database.songVibes).get();
      expect(songVibes, hasLength(1));
      expect(songVibes.single.songId, '1');
      expect(songVibes.single.vibeTagId, 'chill');

      final songs = await database.select(database.songs).get();
      expect(songs, hasLength(3), reason: 'no song may be lost in the rebuild');
      final first = songs.firstWhere((s) => s.id == '1');
      expect(first.title, 'A');
      expect(first.filePath, '/music/a.mp3');
      expect(first.isLiked, isTrue);
      expect(first.playCount, 3, reason: 'play history survives the rebuild');

      final playlists = await database.select(database.playlists).get();
      expect(playlists.single.sourceVibeTagId, 'chill');

      // Settings written before the upgrade must come through untouched.
      final settings = await database.select(database.settings).getSingle();
      expect(settings.seekStepSeconds, 15);
      expect(settings.crossfadeEnabled, isTrue);

      // v10 adds video support; existing rows take the defaults.
      expect(settings.includeVideos, isFalse);
      expect(
        songs.every((song) => !song.isVideo),
        isTrue,
        reason: 'songs scanned before v10 are audio',
      );

      // v14 adds date-added. It can only come from a device scan, so every
      // upgraded row starts unknown rather than being dated to the epoch —
      // which is what keeps them out of the front of "Newest added".
      expect(
        songs.every((song) => song.dateAdded == null),
        isTrue,
        reason: 'songs cached before v14 have no date-added until a rescan',
      );

      // v13 replaces the show/hide boolean with a placement. The fixture had
      // it switched off, so the user must not find the visualizer back.
      expect(
        settings.visualizerPlacement,
        'off',
        reason: 'the old show_visualizer_in_now_playing choice must carry over',
      );
      expect(settings.visualizerBarCount, 40);
      expect(settings.visualizerContrast, 1.0);

      // v13 also adds vibe folders. Existing vibes survive uncategorised —
      // the built-in ids are backfilled by VibeTagRepository.ensureSeeded,
      // not by the migration.
      expect(await database.select(database.vibeCategories).get(), isEmpty);
      expect(
        vibes.every((vibe) => vibe.categoryId == null),
        isTrue,
        reason: 'the new column starts null on an upgraded database',
      );
    },
  );

  test('v13 backfills the built-in vibes into the seeded folders', () async {
    final database = AppDatabase.connect(
      NativeDatabase.memory(
        setup: (rawDb) {
          for (final statement in _v8Schema) {
            rawDb.execute(statement);
          }
          rawDb.execute('PRAGMA user_version = 8');
        },
      ),
    );
    addTearDown(database.close);

    await VibeTagRepository(database: database).ensureSeeded();

    final categories = await database.select(database.vibeCategories).get();
    expect(categories.map((c) => c.id), contains('mood'));

    final vibes = await database.select(database.vibeTags).get();
    expect(
      vibes.firstWhere((v) => v.id == 'chill').categoryId,
      'mood',
      reason: 'a surviving built-in vibe should land in its original folder',
    );
    expect(vibes.firstWhere((v) => v.id == 'happy').categoryId, 'feeling');
  });

  test('a fresh install creates the current schema directly', () async {
    final database = AppDatabase.connect(NativeDatabase.memory());
    addTearDown(database.close);

    await database
        .into(database.vibeTags)
        .insert(
          VibeTagsCompanion.insert(id: 'v', label: 'Vibe', colorHex: '#FFFFFF'),
        );
    await database
        .into(database.songs)
        .insert(
          SongsCompanion.insert(
            id: 's',
            filePath: '/music/a.mp3',
            title: 'A',
            artist: 'Artist',
            album: 'Album',
            durationMs: 1000,
          ),
        );
    await database
        .into(database.songVibes)
        .insert(SongVibesCompanion.insert(songId: 's', vibeTagId: 'v'));

    final rows = await database.select(database.songVibes).get();
    expect(rows.single.vibeTagId, 'v');
  });
}
