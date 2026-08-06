// Prints a summary of a Zivybb database file, for verifying migrations
// against a copy pulled off the device.
import 'dart:io';
import 'package:sqlite3/sqlite3.dart';

int _count(Database db, String table) {
  try {
    return db.select('SELECT COUNT(*) AS c FROM $table').first['c'] as int;
  } catch (_) {
    return -1;
  }
}

void main(List<String> args) {
  final db = sqlite3.open(args.single, mode: OpenMode.readOnly);
  print('user_version: ${db.select('PRAGMA user_version').first.values.first}');

  final tables = db
      .select("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
      .map((r) => r['name'] as String)
      .where((n) => !n.startsWith('sqlite_'))
      .toList();
  print('tables: ${tables.join(', ')}');

  for (final t in [
    'songs',
    'vibe_tags',
    'mood_tags',
    'song_vibes',
    'playlists',
    'playlist_songs',
    'equalizer_presets',
    'playback_sessions',
  ]) {
    if (tables.contains(t)) print('  $t: ${_count(db, t)}');
  }

  print('liked: ${db.select('SELECT COUNT(*) AS c FROM songs WHERE is_liked=1').first['c']}');
  print('with history: ${db.select('SELECT COUNT(*) AS c FROM songs WHERE play_count>0').first['c']}');

  for (final t in ['songs', 'settings']) {
    final cols = db.select("PRAGMA table_info('$t')").map((r) => r['name']).toList();
    print('$t cols: ${cols.join(', ')}');
  }
  db.dispose();
}
