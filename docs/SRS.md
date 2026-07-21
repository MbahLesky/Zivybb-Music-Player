# Software Requirements Specification

## Zivybb — Local Music Player Application

## 1. Introduction

### 1.1 Purpose

This document specifies the functional and non-functional requirements for Version 1 of Zivybb, a Flutter-based local music player for Android. Version 1 targets personal use, with the application architected so it can later be extended for public release.

### 1.2 Scope

Zivybb allows a user to browse, organize, and play music files stored locally on an Android device. The application supports playlist and folder-based organization, mood/energy tagging, visual customization, and library-protection features such as backup, restore, and missing-file recovery. Streaming integration and related capabilities are explicitly out of scope for this version and are listed in Section 5, Future Considerations.

### 1.3 Definitions

- **Crossfade** — a smooth audio transition where one track fades out as the next fades in.
- **Gapless playback** — playback with no silence or interruption between consecutive tracks.
- **Mood/energy tag** — a manually assigned label (e.g., energetic, chill, sad) describing a song's character.
- **Preview clip** — a short (approximately 30-second) excerpt of a track.

## 2. Overall Description

### 2.1 Product Perspective

Zivybb is a standalone Android application built with Flutter. Version 1 operates entirely on local device storage with no server or account dependency.

### 2.2 User Characteristics

The initial user is the application's developer, using the app for personal daily listening. The future public release will target general Android users seeking a customizable local music player.

### 2.3 Operating Environment

Android smartphones and tablets, built and run via the Flutter framework.

## 3. Functional Requirements

### 3.1 Playback

| ID | Requirement | Priority |
|---|---|---|
| F-1.1 | The system shall play, pause, and resume the currently selected track. | High |
| F-1.2 | The system shall allow skipping to the next or previous track. | High |
| F-1.3 | The system shall support shuffle playback across a playlist, folder, or the full library. | High |
| F-1.4 | The system shall support crossfade transitions between tracks. | Medium |
| F-1.5 | The system shall support gapless playback between consecutive tracks. | Medium |
| F-1.6 | The system shall provide equalizer presets that the user can select and apply. | Medium |

### 3.2 Browsing and Organization

| ID | Requirement | Priority |
|---|---|---|
| F-2.1 | The system shall allow browsing of music by user-created playlists. | High |
| F-2.2 | The system shall allow browsing of music by device folder structure. | High |
| F-2.3 | The system shall allow sorting of songs by attributes including duration (e.g., above or below one minute). | Medium |
| F-2.4 | The system shall allow creation, editing, and deletion of playlists. | High |
| F-2.5 | The system shall allow songs to be marked as liked or favorite. | High |
| F-2.6 | The system shall allow the user to manually tag songs with a mood or energy label. | Medium |

### 3.3 Customization

| ID | Requirement | Priority |
|---|---|---|
| F-3.1 | The system shall allow the user to select and apply color themes across the app interface. | Medium |
| F-3.2 | The system shall display a wave visualizer that reacts to the beat of the currently playing track. | Medium |
| F-3.3 | The system shall allow the user to customize the color of the wave visualizer. | Medium |
| F-3.4 | The system shall automatically switch between light and dark mode based on time of day. | Medium |

### 3.4 Smart Features

| ID | Requirement | Priority |
|---|---|---|
| F-4.1 | The system shall support playing a short preview clip (approximately 30 seconds) of a track before advancing to the next. | Low |
| F-4.2 | The system shall automatically generate playlists based on the mood/energy tags present in the library. | Medium |
| F-4.3 | The system shall offer a song discovery feature that surfaces random, lesser-played tracks from artists already in the library. | Low |

### 3.5 Backup and Recovery

| ID | Requirement | Priority |
|---|---|---|
| F-5.1 | The system shall allow the user to back up playlists, liked songs, and settings. | High |
| F-5.2 | The system shall allow the user to restore playlists, liked songs, and settings from a backup. | High |
| F-5.3 | The system shall detect when a referenced music file is missing and handle it gracefully rather than crashing. | High |
| F-5.4 | The system shall provide an optional auto-detection feature that searches the device for a missing file by name or metadata and re-links it automatically when found. | Medium |

### 3.6 Tag Editing

| ID | Requirement | Priority |
|---|---|---|
| F-6.1 | The system shall allow the user to edit a song's metadata, including artist, album, and title. | Medium |

## 4. Non-Functional Requirements

| ID | Requirement | Priority |
|---|---|---|
| N-1 | The application shall run on current Android OS versions supported by Flutter. | High |
| N-2 | The beat-reactive visualizer shall render without introducing perceptible audio lag or stutter. | Medium |
| N-3 | The optional file auto-detection scan shall not block app startup and should run in the background where possible. | Medium |
| N-4 | The application shall handle common local audio formats reliably. | High |
| N-5 | The user interface shall remain responsive while switching between color themes and light/dark modes. | Medium |

## 5. Future Considerations (Out of Scope for Version 1)

- Streaming service integration (e.g., Spotify, Apple Music, YouTube Music).
- Offline downloads of streamed tracks.
- Automated audio analysis to detect mood/energy instead of manual tagging.
- Last.fm scrobbling and listening-history profiles.
- Synchronized lyrics display.
- Social features such as playlist sharing and collaborative playlists.
- Advanced full-text search with filters.
- Podcast and internet radio support.
- Cross-device sync of playlists and library data.
- A recommendation engine based on listening habits.
