# Interface Design and Brand Guide

## Zivybb — Local Music Player Application

## 1. Brand Identity

**Name:** Zivybb
**Personality:** Energetic but calm, personal, tactile. Zivybb should feel like a music player made by someone who actually cares how their music looks and feels while playing — expressive, not sterile like a stock system player.

**Tone of voice (in-app copy):** Simple, direct, a little warm. No corporate jargon. Favor short labels ("Liked", "Discover", "Recently Added") over verbose ones.

## 2. Color System

Zivybb is built around user-customizable themes, but ships with a default palette and rules for how any theme must be constructed.

### Default Theme — "Zivybb Dark" (default adaptive-mode base)

| Role | Color | Hex |
|---|---|---|
| Background | Deep charcoal | `#121212` |
| Surface (cards, sheets) | Elevated charcoal | `#1E1E1E` |
| Primary accent | Electric violet | `#7C4DFF` |
| Secondary accent | Warm coral | `#FF6E6E` |
| Text — primary | Off-white | `#F5F5F5` |
| Text — secondary | Muted gray | `#A0A0A0` |
| Success / positive | Soft green | `#4CD97B` |
| Warning / missing file | Amber | `#FFB020` |

### Default Theme — "Zivybb Light" (adaptive daytime base)

| Role | Color | Hex |
|---|---|---|
| Background | Off-white | `#FAFAFA` |
| Surface | White | `#FFFFFF` |
| Primary accent | Electric violet | `#6B3FD9` |
| Secondary accent | Warm coral | `#E85A5A` |
| Text — primary | Near-black | `#1A1A1A` |
| Text — secondary | Gray | `#6B6B6B` |

### Custom Theme Rules

- Any user-selected theme must maintain a minimum 4.5:1 contrast ratio between text and background (WCAG AA).
- The visualizer color may be customized independently of the theme accent color, but defaults to the theme's primary accent.
- Warning/error colors (missing files, failed backup) are **not** themeable — they stay consistent so the user always recognizes them.

## 3. Typography

- **Primary typeface:** System default (Roboto on Android) unless a custom font is added later — prioritize load performance and native feel over a bespoke typeface for V1.
- **Type scale:**

| Style | Size | Weight | Use |
|---|---|---|---|
| Display | 28sp | Bold | Now Playing track title |
| Title | 20sp | SemiBold | Screen titles, playlist names |
| Body | 16sp | Regular | Song titles in lists, general copy |
| Caption | 13sp | Regular | Artist/album secondary text, timestamps |
| Label | 12sp | Medium | Buttons, tags, chips |

## 4. Iconography

- Use a single consistent icon set throughout (e.g., a Material Symbols/rounded icon family) — no mixing icon styles.
- Custom icons (visualizer toggle, mood tags) should match the stroke weight and corner radius of the base icon set.
- Mood tags get a small color-coded dot or chip rather than a unique icon per mood, to keep the system scalable as users add moods.

## 5. Spacing and Layout

- Base unit: 8px grid. All padding/margin values are multiples of 8 (4px allowed only for tight inline spacing, e.g., icon-to-label gaps).
- Standard screen padding: 16px horizontal.
- List item height: 56–64px depending on whether a secondary text line is present.
- Card corner radius: 12px. Chips/tags: fully rounded (pill shape).

## 6. Components

### Buttons
- Primary action: filled, accent color background, white/near-white text.
- Secondary action: outlined or text-only, accent color text.
- Destructive action (remove from library, delete backup): uses the warning/error color, always paired with a confirmation step.

### Mini-Player
- Persistent bottom bar: album art thumbnail (or generic icon if none), title/artist, play/pause, subtle progress indicator along the top edge of the bar.
- Expands into the full Now Playing screen via tap or swipe-up gesture.

### Now Playing Visualizer
- Wave visualizer sits behind or above the transport controls, reacting to beat/amplitude in real time.
- Visualizer intensity should be subtle enough not to distract from readability of the track title and controls.

### Cards (Playlists, Discovery items)
- Consistent aspect ratio for playlist thumbnails.
- Auto-generated (mood-based) playlists are visually distinguished from manual playlists with a small badge or accent border — not a completely different card style.

## 7. Motion

- Screen transitions: standard platform transitions (no custom page-transition animations for V1) to keep performance predictable.
- Visualizer animation: continuous, tied to audio amplitude/beat detection, capped to avoid excessive battery/CPU use.
- Micro-interactions (like/favorite toggle, mood tag selection): quick (150–200ms), subtle scale or color transitions — no bouncy/exaggerated easing.

## 8. Dark Mode Behavior

- Adaptive dark mode switches automatically based on time of day (see SRS F-3.4), but the user can override manually from Settings.
- Theme and visualizer colors should be defined per-mode (light/dark) so a custom accent color still has an appropriate light and dark counterpart rather than being hardcoded to one brightness.

## 9. Accessibility

- Minimum touch target size: 48x48dp.
- All interactive icons have an accessible label (screen-reader support), even though a visual label may not always be shown.
- Do not rely on color alone to convey state (e.g., missing file) — pair color with an icon or text label.
