# Development Plan

## Zivybb — Local Music Player Application

This document expands the high-level 4-week roadmap (from `Project-Charter.md`) into a task-level plan with deliverables and checkpoints for each week.

## Week 1 — Foundation and Core Playback

**Goal:** A working app that scans the device, lists local songs, and plays them.

| Day(s) | Tasks |
|---|---|
| 1 | Project scaffolding: repo setup, folder structure, dependencies (audio engine, state management, local storage), lint config. |
| 2 | Local file scanning: permission handling, device media query, build initial `Song` model and in-memory library. |
| 3 | Home/Library screen: basic song list UI, navigation shell, mini-player scaffold. |
| 4 | Core playback: play/pause/skip wired to the audio engine, Now Playing screen (basic, no visualizer yet). |
| 5 | Shuffle implementation, persistence of scanned library to local storage, smoke-test on a real device. |

**Deliverable:** App installs, scans the library, and plays songs with play/pause/skip/shuffle.

## Week 2 — Organization and Personalization

**Goal:** The user can organize their library the way they think about it.

| Day(s) | Tasks |
|---|---|
| 1 | Playlist data model and CRUD (create, rename, delete, reorder songs). |
| 2 | Playlist List and Playlist Detail screens. |
| 3 | Folder Browser screen using device folder structure; sort-by-duration control. |
| 4 | Liked/favorite songs; mood/energy tagging model and Mood Tagging screen/modal. |
| 5 | Adaptive dark mode (time-of-day based theme switch) with manual override in Settings. |

**Deliverable:** Playlists, folder browsing, favorites, and mood tagging are fully usable.

## Week 3 — Signature Experience

**Goal:** The features that make Zivybb feel different from a stock player.

| Day(s) | Tasks |
|---|---|
| 1–2 | Beat-reactive wave visualizer: amplitude/beat analysis pipeline and rendering widget, performance-tuned (`RepaintBoundary`, isolate work if needed). |
| 3 | Color theme customization screen; visualizer color customization; theme persistence. |
| 4 | Mood-based 30-second preview clips; auto-generated playlists derived from mood tags. |
| 5 | Gapless playback and crossfade between tracks; regression-test playback stability. |

**Deliverable:** Visualizer, theming, preview clips, auto-playlists, gapless/crossfade all working together without performance regressions.

## Week 4 — Resilience, Editing, and Polish

**Goal:** The app is trustworthy with a real, messy local library and ready for daily personal use.

| Day(s) | Tasks |
|---|---|
| 1 | Backup/restore: serialize playlists, favorites, tags, and settings; restore flow with confirmation. |
| 2 | Missing-file handling: graceful skip on missing file, Missing Files screen. |
| 3 | Auto-detection/re-linking: background scan matching missing files by filename/metadata. |
| 4 | Tag editor (artist/album/title editing) and equalizer presets. |
| 5 | UI polish pass, accessibility check (contrast, touch targets), full manual regression test across all screens, bug fixing. |

**Deliverable:** Version 1 feature-complete, backed up safely, resilient to missing files, ready for daily personal use.

## Testing Checkpoints

- **End of Week 1:** Manual smoke test — scan, list, and play a real device library.
- **End of Week 2:** Manual test of full organization workflow (create playlist, tag songs, browse folders).
- **End of Week 3:** Performance check on visualizer + playback under real usage; verify no audio glitches from crossfade/gapless.
- **End of Week 4:** Full regression pass per `Testing-Strategy.md`; backup/restore tested with a deliberately corrupted/missing-file scenario.

## Definition of Done (Version 1)

- All functional requirements in `SRS.md` Section 3 are implemented.
- All non-functional requirements in `SRS.md` Section 4 are verified.
- No known crashes during normal use across the full feature set.
- Backup/restore verified to correctly round-trip playlists, favorites, tags, and settings.
- App used as the developer's daily driver for at least a few days without blocking issues before public release is considered.

## Beyond Version 1

Once the personal-use milestone is stable, prioritization for public release and future features (streaming integration, lyrics, social features, etc.) follows the list in `SRS.md` Section 5, to be re-scoped into a Version 2 plan at that time.
