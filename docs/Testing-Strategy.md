# Testing Strategy

## Zivybb — Local Music Player Application

## 1. Testing Philosophy

Zivybb is a single-developer project targeting personal daily use before any public release, so testing effort is focused on **preventing crashes and data loss** (a corrupted library or lost playlist is much worse than a minor visual bug) and on **locking in fixes** so regressions don't silently return.

## 2. Test Types

| Type | Scope | Tooling |
|---|---|---|
| Unit tests | Repositories, controllers, domain logic (e.g., mood-tag grouping, missing-file matching logic) | `flutter_test` |
| Widget tests | Individual screens and components in isolation (e.g., Playlist Detail renders correctly, mini-player reflects playback state) | `flutter_test` |
| Integration tests | End-to-end flows across multiple screens (e.g., create playlist → add songs → play) | `integration_test` |
| Manual testing | Real-device behavior with an actual local music library, including edge cases (very large library, missing files, low storage) | Manual, per checkpoint in `Development-Plan.md` |

## 3. Priority Areas for Automated Coverage

1. **Playback correctness** — play/pause/skip/shuffle state transitions, crossfade and gapless boundaries.
2. **Library data integrity** — playlist CRUD, favorites, mood tagging, ensuring no duplicate or orphaned entries.
3. **Missing-file handling** — a missing file must never crash playback or block library loading; auto-detection matching logic needs dedicated unit tests with fixture file names.
4. **Backup/restore round-trip** — a backup created from a given state must restore to an equivalent state; this is the single highest-risk area for data loss and should have the strongest test coverage.

## 4. Manual QA Checklist (per release candidate)

- [ ] Fresh install scans and lists a real device library correctly.
- [ ] Play, pause, skip forward/backward, and shuffle all behave correctly.
- [ ] Crossfade and gapless playback produce no audible glitches across a variety of tracks.
- [ ] Playlists can be created, renamed, reordered, and deleted without errors.
- [ ] Mood tags can be applied and auto-generated playlists update accordingly.
- [ ] Theme and visualizer color changes apply immediately and persist after restart.
- [ ] Adaptive dark mode switches at the expected time and can be manually overridden.
- [ ] A deliberately renamed/moved file is detected as missing and does not crash the app.
- [ ] Auto-detection successfully re-links a moved file in a common case (same filename, new folder).
- [ ] Backup, then restore, produces an equivalent library/playlist/settings state.
- [ ] Tag editing (artist/album/title) saves correctly and reflects across all screens showing that song.
- [ ] Equalizer presets apply and persist across sessions.

## 5. Regression Policy

- Every confirmed bug gets a corresponding automated test before the fix is considered complete, per `debugging-methodology` conventions.
- The manual QA checklist above is run in full at the end of Week 4 (per `Development-Plan.md`) and before any future public release candidate.

## 6. Performance Testing

- Visualizer rendering is checked for dropped frames during continuous playback on the target test device.
- Library scanning and missing-file auto-detection are checked to confirm they do not block the UI thread (see `Architecture-Overview.md` Section 2).

## 7. Out of Scope for Version 1

- Automated UI testing across multiple device sizes/OS versions (single-developer, single primary test device for personal-use phase).
- Load/stress testing with libraries beyond realistic personal collection sizes.
- Automated accessibility testing (manual accessibility checks only — see `Interface-Design-Brand-Guide.md` Section 9).
