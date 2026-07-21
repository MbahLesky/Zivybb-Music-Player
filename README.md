# Zivybb

Zivybb is a Flutter-based local music player for Android. Version 1 is built for personal use, with a public release planned for a later phase once the core experience is validated.

## About

Zivybb combines dependable local playback with a highly customizable, mood-aware listening experience:

- **Playback:** play, pause, skip, shuffle, crossfade, gapless playback, equalizer presets.
- **Organization:** browse by playlist or folder, sort by attributes like duration, create and manage playlists, mark favorites, tag songs by mood/energy.
- **Customization:** color themes, beat-reactive wave visualizers with customizable colors, adaptive dark mode based on time of day.
- **Smart features:** mood-based 30-second preview clips, auto-generated mood/energy playlists, song discovery for deep cuts from known artists.
- **Library protection:** backup and restore of playlists/favorites/settings, graceful handling of missing files, auto-detection and re-linking of relocated files.
- **Tag editing:** edit song metadata (artist, album, title) directly in the app.

Streaming integration, offline downloads, and other larger features are planned for future releases — see [`docs/SRS.md`](docs/SRS.md) for the full future-considerations list.

## Status

🚧 In active development — targeting a personal-use release within a few weeks, followed by a public release.

## Tech Stack

- **Framework:** Flutter / Dart
- **Platform:** Android (Version 1)

## Documentation

Project documentation lives in [`docs/`](docs):

- [`docs/Project-Charter.md`](docs/Project-Charter.md) — project purpose, scope, stakeholders, timeline, and success criteria.
- [`docs/SRS.md`](docs/SRS.md) — full software requirements specification (functional and non-functional requirements).

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
