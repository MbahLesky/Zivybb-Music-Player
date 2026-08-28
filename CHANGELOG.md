# Changelog

Notable changes to Zivybb, newest first.

Versions follow the rules in `docs/Coding-Standards.md` §10.1: patch for fixes,
minor for additive features, major for a break in continuity. Entries are grouped
by what they do for the user rather than by the files touched.

The 1.0.0 and 1.1.0 sections below are reconstructed from git history — the version
number was not maintained per-change before this policy existed, so they summarise a
range of work rather than a single release.

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
