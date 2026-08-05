# Zivybb

Zivybb is a Flutter-based local music player for Android. Version 1 is built for personal use, with a public release planned for a later phase once the core experience is validated.

## About

Zivybb combines dependable local playback with a highly customizable, mood-aware listening experience:

- **Playback:** play, pause, skip, shuffle, repeat, playback speed, crossfade, gapless playback, equalizer presets, and a sleep timer.
- **Background playback:** keeps playing with a lock-screen and notification media control, including a like button.
- **Organization:** browse by playlist or folder, search by title/artist/album, sort by title, artist, album, duration, or listening history, create and manage playlists, mark favorites, tag songs by mood/energy.
- **Queue:** see what's up next, reorder it, remove tracks, or jump straight to one.
- **Customization:** color themes, seven wave-visualizer styles with customizable colors, adaptive dark mode based on time of day.
- **Visualizer:** simulated by default; opt into real audio reactivity in Theme Customization (see the note below).
- **Smart features:** mood-based 30-second preview clips, auto-generated mood/energy playlists, song discovery for deep cuts from known artists.
- **Library protection:** backup, restore, and export of playlists/favorites/settings, graceful handling of missing files, auto-detection and re-linking of relocated files.
- **Tag editing:** edit song metadata (artist, album, title) directly in the app.
- **Resume:** reopens on the track, position, and transport settings you left off with.

Streaming integration, offline downloads, and other larger features are planned for future releases — see [`docs/SRS.md`](docs/SRS.md) for the full future-considerations list.

## Status

🚧 In active development — targeting a personal-use release within a few weeks, followed by a public release.

## Tech Stack

- **Framework:** Flutter / Dart
- **Platform:** Android (Version 1)

## Brand mark

The Zivybb mark is a calligraphic **ZV** monogram. One looping stroke draws
the Z — along the bottom, up and back over the top, then down across its own
path and away into a descending tail — and threads through a second stroke
sweeping the V, so the two interlace like a ribbon. Both are brush strokes:
the outline comes from offsetting a Bézier centreline by a width that swells
on the downstrokes and pinches at the turns, which is what gives the
thick/thin calligraphic weight rather than a uniform pen line.

Where the strokes cross, the one in front punches a small transparent gap
through the one behind — that alternation is what makes the weave read.

[`tools/zivybb_logo.py`](tools/zivybb_logo.py) is the source of truth. Run
`python3 tools/zivybb_logo.py` (needs `numpy` and `Pillow`) to regenerate:

- `assets/images/zivybb_logo.svg` / `zivybb_icon.svg` — design sources, both
  generated; don't hand-edit them.
- `assets/images/*.png` and the Android launcher icons plus adaptive-icon
  layers.

[`lib/shared/widgets/zivybb_logo.dart`](lib/shared/widgets/zivybb_logo.dart)
draws the same mark in-app (app bar, and anywhere else it's needed) so it
stays crisp at any size. Its geometry constants mirror the Python ones —
change one and change the other.

## Visualizer and the microphone permission

The visualizer runs off a simulated waveform by default — a deterministic
animation seeded by the track, not an analysis of the audio.

Turning on **React to real audio** (Settings → Theme → Theme Customization)
switches it to real frequency bands read from the audio actually playing, via
`android.media.audiofx.Visualizer` bound to the current audio session. Android
gates that API behind `RECORD_AUDIO` because it can observe the output mix,
so enabling the toggle prompts for the microphone permission. **Zivybb never
records anything and never opens the microphone**; the permission exists
solely to read levels from its own playback.

Two things worth knowing:

- The permission is only *requested* when you enable the toggle, but it has to
  be *declared* in the manifest for the feature to exist at all — and Play
  Store builds its permissions list from the manifest. So the listing mentions
  microphone access whether or not you ever switch it on. Deleting the
  `RECORD_AUDIO` line from `AndroidManifest.xml` removes it from the listing
  and leaves the visualizer permanently simulated, which is a reasonable trade
  if you'd rather not explain it to users.
- If the capture can't start — permission declined, the effect unavailable on
  the device, or another app holding the session — the visualizer silently
  falls back to the simulation rather than failing.

## Building a release

Debug and profile builds need no setup. For a signed release build:

1. Generate a keystore:
   `keytool -genkey -v -keystore ~/zivybb-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias zivybb`
2. Copy [`android/key.properties.example`](android/key.properties.example) to
   `android/key.properties` and fill it in. That file, and any `.jks` /
   `.keystore`, are gitignored — never commit them.
3. `flutter build appbundle --release`

Without `android/key.properties`, release builds fall back to the debug
signing key so `flutter run --release` still works locally.

## Documentation

Project documentation lives in [`docs/`](docs):

- [`docs/Project-Charter.md`](docs/Project-Charter.md) — project purpose, scope, stakeholders, timeline, and success criteria.
- [`docs/SRS.md`](docs/SRS.md) — full software requirements specification (functional and non-functional requirements).
- [`docs/Folder-Structure.md`](docs/Folder-Structure.md) — project folder and file organization.
- [`docs/Screens.md`](docs/Screens.md) — inventory of every app screen and how they connect.
- [`docs/Coding-Standards.md`](docs/Coding-Standards.md) — naming, formatting, state management, and testing conventions.
- [`docs/Entity-Diagrams-UML.md`](docs/Entity-Diagrams-UML.md) — ER diagram, domain class diagram, and key sequence diagrams.
- [`docs/Interface-Design-Brand-Guide.md`](docs/Interface-Design-Brand-Guide.md) — brand identity, color system, typography, and component guidelines.
- [`docs/Architecture-Overview.md`](docs/Architecture-Overview.md) — layered architecture, data flow, and persistence strategy.
- [`docs/Development-Plan.md`](docs/Development-Plan.md) — detailed week-by-week task breakdown and definition of done.
- [`docs/Testing-Strategy.md`](docs/Testing-Strategy.md) — test types, priority coverage areas, and manual QA checklist.

All project documents are maintained in Markdown in this repository for easy versioning and review.

## Roadmap

| Phase | Focus |
|---|---|
| Week 1 | Project setup, local file scanning, core playback |
| Week 2 | Playlists, favorites, folder browsing, sorting, mood tagging, adaptive dark mode |
| Week 3 | Wave visualizers, color theming, preview clips, auto-generated mood playlists, gapless playback, crossfade |
| Week 4 | Backup/restore, missing-file auto-detection, tag editing, equalizer presets, polish and testing |

## License

TBD.
