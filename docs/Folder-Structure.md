# Folder Structure

## Zivybb — Local Music Player Application

This document defines the project's folder and file organization. Zivybb follows a **feature-first** structure: code is grouped by feature (playback, library, playlists, etc.) rather than by technical layer, so each feature's UI, logic, and data access live close together.

## Top-Level Structure

```
zivybb/
├── android/                  # Native Android project files
├── lib/                      # All Dart application source code
├── assets/                   # Images, icons, fonts
├── test/                     # Unit, widget, and integration tests
├── docs/                     # Project documentation (this folder)
├── pubspec.yaml              # Package manifest and dependencies
├── analysis_options.yaml     # Lint / static analysis rules
└── README.md
```

## `lib/` Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Root widget, routing, theme setup
│
├── core/                     # App-wide concerns, no feature-specific logic
│   ├── constants/            # App-wide constants (durations, keys, defaults)
│   ├── theme/                # Color themes, typography, light/dark definitions
│   ├── utils/                # Formatters, extensions, helper functions
│   └── services/             # Cross-cutting services (audio engine wrapper,
│                              # file scanning service, storage service)
│
├── data/                     # Data layer shared across features
│   ├── models/                # Song, Playlist, MoodTag, Settings, etc.
│   ├── repositories/          # Abstractions over data sources
│   └── datasources/           # Local DB access, file system access
│
├── features/                 # One folder per feature
│   ├── playback/
│   │   ├── presentation/      # Now Playing screen, mini-player, controls
│   │   ├── application/       # Playback state/controllers
│   │   └── domain/             # Playback-specific logic (crossfade, gapless)
│   │
│   ├── library/
│   │   ├── presentation/      # Home/library screen, folder browser
│   │   └── application/
│   │
│   ├── playlists/
│   │   ├── presentation/      # Playlist list, playlist detail
│   │   └── application/
│   │
│   ├── visualizer/
│   │   ├── presentation/      # Wave visualizer widget
│   │   └── application/       # Beat-detection / rendering logic
│   │
│   ├── mood_tagging/
│   │   ├── presentation/      # Tagging UI, auto-generated mood playlists
│   │   └── application/
│   │
│   ├── backup/
│   │   ├── presentation/      # Backup/restore screen
│   │   └── application/
│   │
│   ├── tag_editor/
│   │   └── presentation/      # Metadata editing screen
│   │
│   └── settings/
│       ├── presentation/      # Settings, theme picker, equalizer presets
│       └── application/
│
├── shared/                   # Reusable, feature-agnostic UI
│   ├── widgets/                # Buttons, cards, sliders, dialogs
│   └── extensions/             # Shared Dart extensions
│
└── routes/                   # Route definitions and navigation
```

## Conventions

- Each feature folder is self-contained: presentation (widgets/screens), application (state management), and domain (business logic) live together.
- Shared, feature-agnostic code goes in `core/` or `shared/`, never duplicated across features.
- Data models used by more than one feature live in `data/models/`; feature-specific view models stay inside that feature's folder.
- Test files mirror the `lib/` structure inside `test/` (e.g., `test/features/playback/...`).

## Assets

```
assets/
├── images/         # Illustrations, empty-state graphics
├── icons/          # Custom icons not covered by an icon package
└── fonts/          # Custom typefaces, if any
```

Declare all asset paths explicitly in `pubspec.yaml`.
