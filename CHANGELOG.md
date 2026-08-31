# Changelog

Notable changes to Zivybb, newest first.

Versions follow the rules in `docs/Coding-Standards.md` §10.1: patch for fixes,
minor for additive features, major for a break in continuity. Entries are grouped
by what they do for the user rather than by the files touched.

The 1.0.0 and 1.1.0 sections below are reconstructed from git history — the version
number was not maintained per-change before this policy existed, so they summarise a
range of work rather than a single release.

## 1.3.0 — 2026-08-29

### Added
- **Library sources** (Settings ▸ Library): the library no longer swallows
  everything the device calls audio. WhatsApp voice notes, call recordings,
  ringtones, notification blips and alarms are left out by default — by the
  folder they sit in and by a minimum track length — and every folder on the
  device is listed with a switch, so anything the guess gets wrong is one tap
  from being put back. Changing any of it rescans straight away, and clears
  out what an earlier scan had already let in.
- **Swipe gestures on Now Playing.** Across the artwork: sideways for the
  previous/next track, up and down for the device media volume, with an
  on-screen readout. The seek bar and the buttons below it are untouched.
- **A compact Now Playing layout**, toggled from the app bar and remembered.
  Artwork, title and the three transport buttons; shuffle, repeat, like and
  save to playlist move into the "more" sheet rather than disappearing.
- The mini player now follows you into Settings and its sub-screens.

### Changed
- The media scan also drops anything the media store itself files as a
  ringtone, notification, alarm, podcast or audiobook, which it previously
  accepted whenever the "is music" flag was merely unset.
- Backups carry the library-source filter and the Now Playing layout choice
  (format version 5). Older backups restore as before and leave both alone.

## 1.4.0 — 2026-08-31

### Added
- **One set of sort and filter controls on every list.** All Songs, Liked, a
  device folder and a playlist now share the same search box and the same
  "Sort & filter" sheet, instead of each screen carrying its own smaller,
  differently-worded menus. Filters combine — Liked only, Has a vibe, No vibe,
  Never played, plus a vibe folder and a device folder — and the button carries
  a badge saying how many are narrowing the list.
- Sorting is now a field plus a direction: date added, title, length, artist,
  album, times played, or last played, each reversible. The direction is
  labelled in the words of the field it applies to ("Most played first",
  "Recently played first") rather than "ascending".
- **The visualizer can now genuinely be the seek bar.** The wide styles (bars,
  mirror, line, ribbon) become the progress track itself — played in colour,
  the rest grey — and scrub when dragged. The circular styles (radial,
  particles) become a ring around the artwork, with the artwork inside it.
  Bloom has no direction to read progress along, so the option is disabled and
  says why.

### Fixed
- **Rhythm mode showing an empty board.** With real-audio capture switched on
  but reporting nothing to follow — a silent passage, or a device whose capture
  attaches and then returns nothing — no tiles were ever spawned and the game
  sat empty. It now falls back to the stand-in pattern after a couple of
  seconds of silence, and hands control back the moment real beats arrive.
- The stand-in pattern's beats used to be generated in one burst that all
  landed on the same instant. They are now laid down ahead of the playhead, so
  each tile arrives when its beat does.
- Rhythm mode's banner said the tiles were following the song whenever a
  capture was merely attached. It now reports what the board is actually using.
- **The visualizer barely reacting to the beat.** The stand-in waveform was two
  fixed sine waves — identical for every track. It is now shaped like a drum
  pattern: low bars carry the kick and high bars the hats, at a pace seeded
  from the track, so a slow song and a driving one no longer look the same. On
  real audio, rises are emphasised so a hit stands out from a sustained note,
  and levels are scaled against a rolling loudness so quiet and loud masters
  both fill the display and what shows is the track's own dynamics.
- Bars now build in at the start of a track and drop away across its last
  seconds, rather than stopping dead.

### Changed
- Rhythm mode puts the title, scores and transport buttons above the board.

## 1.3.0 — 2026-08-31

### Added
- **Library sources** (Settings ▸ Library). Zivybb no longer treats every audio
  file on the device as a song. WhatsApp voice notes, call recordings,
  ringtones, notification blips and alarms are left out by default — going by
  the folder they sit in and by a minimum track length — and every folder on
  the device is listed with a switch, so anything the guess gets wrong can be
  put back. Ringtones, notifications, alarms, podcasts and audiobooks the media
  store has labelled as such are always skipped.
- **Swipe gestures on Now Playing.** Across the artwork: sideways to change
  track, up and down for the device volume, with an on-screen readout. The
  gesture area stops above the seek bar so it never fights the slider or the
  buttons.
- **A compact Now Playing layout**, toggled from the app bar or Settings ▸
  Display: artwork, title, and previous/play/next, plus vibes and "more".
  Shuffle, repeat, like and save to playlist move into the "more" sheet rather
  than disappearing.
- The mini player now follows you into Settings and every screen under it.

### Changed
- Turning a source off, or raising the minimum track length, clears the songs
  it excludes out of the library rather than only affecting later scans — along
  with their playlist entries and vibe assignments.
- Backup format version 5 carries the library-source filter and the Now Playing
  layout choice. Older backups restore as before.

## 1.2.1 — 2026-08-27

### Fixed
- Crossfade landing on the wrong track. The outgoing player reaches its end
  just after the swap has already moved the queue on, so its "finished" event
  was read as the *current* track ending and advanced a second time — playing
  the track after the one that had just faded in.
- A short track following a long one being skipped through. The overlap was
  capped against the outgoing track only, so a short incoming track arrived
  already past its own fade point and immediately faded out again.
- The player wedging silently when the next file failed to load. The failure
  left the crossfade mid-ramp forever, which disables the automatic advance
  and every control that checks it.
- A run of unplayable tracks racing through the queue instead of stopping.

## 1.2.0 — 2026-08-27

### Added
- **Rhythm mode**, reached from a new icon on the Now Playing app bar: tiles driven
  by the music that you tap for points, with a per-song high score. Tiles take their
  colour and feel from the visualizer settings.
- High scores are stored per song and cleared with the song when it leaves the library.

### Changed
- The equalizer moved off the Now Playing app bar into the "more" sheet, under
  Edit tags, freeing the app-bar slot for rhythm mode. It is still reachable from
  Settings as before.

### Known limitations
- Rhythm mode follows the real audio only when **Settings ▸ Visualizer ▸ real audio**
  is on (Android, opt-in, needs the microphone permission). With it off the game runs
  against the simulated waveform and says so on screen — the tiles are not tracking
  the beat in that mode.

## 1.1.0 — 2026-08-04

### Added
- Branding and launcher artwork, playback queue screen, sleep timer, library search
  /sort/filter, and session resume on launch.
- Vibe tagging replaced single mood tags: a song can carry several vibes, and vibes
  can be filed into folders.
- Visualizer overhaul — seven styles, tuning controls, placement options, and opt-in
  real-audio capture on Android.
- Video files playable as audio, a custom colour picker, "newest added" sorting, and
  deleting a song from the device.

### Fixed
- The media notification never appearing (an adaptive launcher icon cannot be a
  notification small icon).
- Crossfade stalling on tracks shorter than the crossfade duration.
- Vibe chip labels being unreadable in light mode.

## 1.0.0 — 2026-07-21

### Added
- Initial release: local library scanning, playback with gapless and crossfade,
  playlists, folder browsing, liked songs, equalizer presets, adaptive dark mode,
  backup and restore, and missing-file detection with re-linking.
