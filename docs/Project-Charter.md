# Project Charter

## Zivybb — Local Music Player Application

## 1. Project Purpose

Zivybb is a Flutter-based local music player application for Android. The initial release is intended for personal use by the project owner, with a future public release planned once the core experience is validated. The app aims to combine dependable local playback with a highly customizable, mood-aware listening experience that distinguishes it from standard music players already on the market.

## 2. Objectives

- Deliver a fully functional local music player within a few weeks, covering playback, browsing, and organization.
- Provide a visually distinctive experience through color theming and beat-reactive wave visualizers.
- Introduce mood- and energy-based organization so listening feels tailored to how the user feels in the moment.
- Protect the user's library against common local-file pitfalls, such as deleted or moved files, through backup and auto-recovery features.
- Establish a foundation that can later be extended with streaming integration and offline downloads for public release.

## 3. Scope

### 3.1 In Scope (Version 1 — Personal Use Release)

- Local audio playback: play, pause, skip, shuffle, crossfade, gapless playback.
- Browsing by playlist and folder; sorting by attributes such as track duration.
- Playlist creation and management; liked/favorite songs.
- Manual mood/energy tagging of songs.
- Color theme customization and beat-reactive wave visualizers with customizable colors.
- Adaptive dark mode based on time of day.
- Mood-based 30-second preview clips.
- Auto-generated playlists based on mood/energy tags.
- Song discovery feature surfacing lesser-played tracks from known artists.
- Equalizer presets.
- Metadata/tag editing.
- Backup and restore of playlists, favorites, and settings.
- Graceful handling of missing files, with auto-detection and re-linking by filename or metadata.

### 3.2 Out of Scope (Deferred to Future Releases)

- Streaming service integration (e.g., Spotify, Apple Music, YouTube Music).
- Offline downloads from streaming services.
- Automated audio analysis for mood/energy detection.
- Last.fm scrobbling and listening-history profiles.
- Synchronized lyrics display.
- Social features (sharing playlists, collaborative playlists, activity feed).
- Advanced full-text search across the library.
- Podcast and internet radio support.
- Cross-device sync.
- Recommendation engine based on listening habits.

## 4. Stakeholders

| Role | Description |
|---|---|
| Product Owner / Primary User | Lespa — defines features, approves priorities, and is the initial end user of the app. |
| Developer | Lespa, building the application in Flutter/Dart. |
| Future End Users | General public, once the app is published after the personal-use phase. |

## 5. Timeline

| Phase | Focus |
|---|---|
| Week 1 | Project setup, local file scanning, core playback (play, pause, skip, shuffle). |
| Week 2 | Playlists, favorites, folder browsing, duration-based sorting, mood tagging, adaptive dark mode. |
| Week 3 | Beat-reactive wave visualizers, color theming, preview clips, auto-generated mood playlists, gapless playback, crossfade. |
| Week 4 | Backup/restore, missing-file auto-detection, tag editing, equalizer presets, polish, and testing. |

## 6. Success Criteria

- All Version 1 (in-scope) features are implemented and function reliably on the owner's device.
- The app correctly organizes and plays the owner's full local music library without crashes.
- Missing-file scenarios are handled gracefully, with auto-detection successfully re-linking relocated files in common cases.
- The customization features (themes, visualizers) perform smoothly without noticeable lag during playback.
- The app is stable enough to serve as the owner's daily-use music player before public release is considered.

## 7. Assumptions and Constraints

- Development is being carried out by a single developer with intermediate-to-advanced Flutter/Dart experience.
- Target platform for Version 1 is Android only.
- The timeline assumes a few weeks of active development effort.
- Streaming integration and related features are explicitly deferred and not required for the personal-use milestone.

## 8. Risks

- Auto-detection of missing files may be resource-intensive on startup; mitigation is to run it as an optional or background process.
- Beat-reactive visualizers may be performance-intensive on lower-end devices; should be tested for responsiveness.
- Scope creep from the growing features list could extend the timeline; the future-considerations list exists specifically to contain this.
