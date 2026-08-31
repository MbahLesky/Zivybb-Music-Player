# Screens

## Zivybb — Local Music Player Application

This document lists every screen in Version 1 of Zivybb, its purpose, key UI elements, and how it connects to the rest of the app.

## Screen Inventory

### 1. Splash Screen
- **Purpose:** Brief branded loading screen shown while the app initializes and scans for local files (first launch) or loads the cached library (subsequent launches).
- **Key elements:** Zivybb logo/wordmark, subtle loading indicator.
- **Navigates to:** Home / Library.

### 2. Home / Library Screen
- **Purpose:** Primary landing screen; entry point to the user's music.
- **Key elements:** Tabs or segmented control for Playlists / Folders / All Songs, quick-access to Liked Songs, mini-player docked at the bottom, entry point to Song Discovery.
- **Navigates to:** Playlist Detail, Folder Browser, Now Playing, Song Discovery.

### 3. Folder Browser Screen
- **Purpose:** Browse music using the device's actual folder structure.
- **Key elements:** Folder list/tree, song count per folder. A folder's song list carries the shared search box and "Sort & filter" sheet (see Notes).
- **Navigates to:** Song list within a folder, Now Playing.

### 4. Playlist List Screen
- **Purpose:** Shows all user-created playlists plus auto-generated mood/energy playlists.
- **Key elements:** Playlist cards/thumbnails, "Create Playlist" action, distinction between manual and auto-generated playlists.
- **Navigates to:** Playlist Detail.

### 5. Playlist Detail Screen
- **Purpose:** View and manage the songs within a specific playlist.
- **Key elements:** Song list, reorder controls, add/remove songs, play-all/shuffle-all actions, and the shared search box and "Sort & filter" sheet (see Notes). The playlist's stored order stands until a sort is actually chosen, so opening one never silently reorders it.
- **Navigates to:** Now Playing, Song Discovery (add songs).

### 6. Now Playing Screen
- **Purpose:** Full playback experience for the current track.
- **Key elements:** Beat-reactive wave visualizer, album art (if available), transport controls (play/pause/skip), progress bar, shuffle/crossfade indicators, mood tag display, quick-access to Equalizer and Tag Editor. A compact layout, toggled from the app bar, keeps only the artwork, title and three transport buttons and moves shuffle, repeat, like and save to playlist into the "more" sheet. Swiping across the artwork area changes track sideways and the device media volume vertically. The visualizer can also stand in for the progress bar: the wide styles become the track itself (played in colour, the rest grey), and the circular ones become a ring around the artwork with the artwork inside it.
- **Navigates to:** Tag Editor, Equalizer, Mood Tagging, Rhythm Mode.

### 7. Mood Tagging Screen / Modal
- **Purpose:** Assign or edit a mood/energy label for a song.
- **Key elements:** Preset mood options (Energetic, Chill, Sad, etc.), ability to apply to the current song or in bulk.
- **Navigates to:** Returns to Now Playing or Library.

### 8. Song Discovery Screen
- **Purpose:** Surfaces lesser-played tracks from artists already in the user's library.
- **Key elements:** Card-based or list-based discovery feed, "play" and "add to playlist" quick actions.
- **Navigates to:** Now Playing, Playlist Detail (add to playlist).

### 9. Tag Editor Screen
- **Purpose:** Edit a song's metadata (artist, album, title).
- **Key elements:** Editable text fields per metadata attribute, save/cancel actions.
- **Navigates to:** Returns to previous screen (Library or Now Playing).

### 10. Equalizer Screen
- **Purpose:** Select and apply equalizer presets.
- **Key elements:** Preset list, preview/apply toggle, frequency band visualization (if custom presets are supported).
- **Navigates to:** Returns to Now Playing or Settings.

### 11. Settings Screen
- **Purpose:** Central hub for app configuration.
- **Key elements:** Theme/color customization, adaptive dark mode toggle, visualizer color settings, library sources, backup & restore entry point, about/version info.
- **Navigates to:** Theme Customization, Library Sources, Backup & Restore.

### 11a. Library Sources Screen
- **Purpose:** Decide which of the device's audio files count as music, so voice notes, call recordings and ringtones stay out of the library and out of shuffle.
- **Key elements:** "Skip non-music folders" toggle, minimum track length chips, and a switch per device folder showing its file count; every change rescans immediately.
- **Navigates to:** Returns to Settings.

### 12. Theme Customization Screen
- **Purpose:** Choose color themes and visualizer colors.
- **Key elements:** Color palette picker, live preview of the interface and visualizer.
- **Navigates to:** Returns to Settings.

### 13. Backup & Restore Screen
- **Purpose:** Back up or restore playlists, liked songs, and settings.
- **Key elements:** "Back Up Now" action, list of available backups, "Restore" action with confirmation, status/last-backup timestamp.
- **Navigates to:** Returns to Settings.

### 14. Missing Files Screen (contextual)
- **Purpose:** Surfaces songs whose files could not be found, with an option to trigger auto-detection/re-linking.
- **Key elements:** List of affected songs, "Scan for matches" action, manual re-link option, remove-from-library option.
- **Navigates to:** Returns to Library.

## Navigation Overview

```
Splash
  └─ Home / Library
       ├─ Folder Browser ─────────────┐
       ├─ Playlist List               │
       │     └─ Playlist Detail       │
       ├─ Song Discovery              │
       ├─ Missing Files               │
       └─ Settings                    │
             ├─ Theme Customization   │
             └─ Backup & Restore      │
                                       ▼
                                 Now Playing
                                   ├─ Mood Tagging
                                   ├─ Tag Editor
                                   └─ Equalizer
```

## Notes

- The mini-player is persistent across Home, Folder Browser, Playlist, Discovery, and Settings screens, expanding into the full Now Playing screen on tap.
- **Sort & filter is one shared control, not one per screen.** Every song list
  shows the same search box and the same "Sort & filter" sheet, backed by a
  single `LibraryView`, so a choice made on one list applies to all of them.
  Filters combine (Liked only, Has a vibe, No vibe, Never played, a vibe
  folder, a device folder) and the button is badged with how many are active.
  Sorting is a field (date added, title, length, artist, album, times played,
  last played) plus a direction, labelled in the words of the chosen field.
- Screens deferred to future releases (search with filters, lyrics display, social sharing) are intentionally excluded — see `SRS.md` Section 5.
