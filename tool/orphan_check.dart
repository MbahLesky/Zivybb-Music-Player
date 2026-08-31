// Counts playlist_songs rows that point at a missing playlist or song, to
// confirm what the v12 orphan purge removed was genuinely dangling.
//
//     dart run tool/orphan_check.dart <path-to-zivybb.sqlite>
//
// A developer CLI, not shipped code: stdout is the whole point, and sqlite3
// comes in transitively via drift rather than being a direct dependency.
// ignore_for_file: avoid_print, depend_on_referenced_packages
import 'package:sqlite3/sqlite3.dart';
import 'dart:io';

void main(List<String> args) {
  final db = sqlite3.open(args.single, mode: OpenMode.readOnly);
  int q(String sql) => db.select(sql).first.values.first as int;
  print('playlist_songs total: ${q('SELECT COUNT(*) FROM playlist_songs')}');
  print(
    '  orphaned by song:     ${q('SELECT COUNT(*) FROM playlist_songs WHERE song_id NOT IN (SELECT id FROM songs)')}',
  );
  print(
    '  orphaned by playlist: ${q('SELECT COUNT(*) FROM playlist_songs WHERE playlist_id NOT IN (SELECT id FROM playlists)')}',
  );
  print(
    '  orphaned either way:  ${q('SELECT COUNT(*) FROM playlist_songs WHERE song_id NOT IN (SELECT id FROM songs) OR playlist_id NOT IN (SELECT id FROM playlists)')}',
  );
  print(
    'song_vibes orphaned:    ${q('SELECT COUNT(*) FROM song_vibes WHERE song_id NOT IN (SELECT id FROM songs) OR vibe_tag_id NOT IN (SELECT id FROM vibe_tags)')}',
  );
  stdout.writeln('--- surviving playlist_songs per playlist ---');
  for (final r in db.select(
    'SELECT p.name, COUNT(*) AS c FROM playlist_songs ps JOIN playlists p ON p.id = ps.playlist_id GROUP BY p.id ORDER BY p.name',
  )) {
    print('  ${r['name']}: ${r['c']}');
  }
  db.dispose();
}
