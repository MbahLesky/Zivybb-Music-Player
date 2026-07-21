# Coding Standards

## Zivybb — Local Music Player Application

These standards apply to all Dart/Flutter code in this repository. They exist to keep the codebase consistent and maintainable for a single developer working over an extended period, and to make future collaboration or public contributions straightforward.

## 1. Formatting

- All code is formatted with `dart format` before committing. No manual formatting overrides.
- Line length target: 80 characters (the `dart format` default). Do not disable this.
- Run `flutter analyze` before every commit; the build should have zero analyzer warnings.

## 2. Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `now_playing_screen.dart` |
| Classes, enums, typedefs | `UpperCamelCase` | `PlaylistRepository` |
| Variables, functions, parameters | `lowerCamelCase` | `currentTrack`, `loadPlaylist()` |
| Constants | `lowerCamelCase` with `const` | `const defaultCrossfadeDuration` |
| Private members | prefixed with `_` | `_audioPlayer` |
| Folders | `snake_case` | `mood_tagging/` |

Screen widgets are suffixed `Screen` (e.g., `PlaylistDetailScreen`); reusable widgets are suffixed `Widget` only when the plain name would be ambiguous.

## 3. Project Structure Rules

- Follow the structure defined in `Folder-Structure.md`. New features get their own folder under `features/`; do not add feature-specific logic to `core/` or `shared/`.
- One public class per file, matching the file name.
- Barrel files (`*.dart` re-export files) are permitted per feature folder to simplify imports, but should not be used to hide circular dependencies.

## 4. State Management

- Use a single, consistent state management approach across the app (e.g., Riverpod or Provider — to be finalized at project setup and documented here once chosen).
- Business logic belongs in controllers/notifiers, not inside widget `build()` methods.
- Widgets should be as stateless as possible; lift state up to the feature's application layer.

## 5. Error Handling

- Never let a missing or corrupt file crash the app — wrap file and audio-engine operations in try/catch and degrade gracefully (skip the track, flag it in the Missing Files screen).
- User-facing errors get a clear, plain-language message; technical details are logged, not shown to the user.
- Use typed exceptions for known failure cases (e.g., `MissingFileException`, `BackupRestoreException`) rather than generic `Exception`.

## 6. Comments and Documentation

- Public classes and non-trivial public methods get a `///` doc comment describing intent, not implementation.
- Avoid comments that restate the code; comment on *why*, not *what*, when the "why" isn't obvious.
- TODOs use the format `// TODO(username): description` so they're searchable and attributable.

## 7. Testing

- Every bug fix includes a regression test.
- Business logic (repositories, controllers) is covered by unit tests.
- Key screens have at least one widget test covering the primary interaction path.
- Test files mirror the source path: `lib/features/playback/...` → `test/features/playback/...`.

## 8. Imports

- Order: Dart SDK imports, then Flutter imports, then package imports, then relative project imports, each group separated by a blank line.
- Prefer relative imports within a feature folder; use package imports (`package:zivybb/...`) across feature boundaries.

## 9. Null Safety and Immutability

- The project is fully null-safe; avoid `!` (bang) operator except where nullability is provably impossible — prefer explicit null checks or `??`.
- Prefer immutable data models (`final` fields, `copyWith` methods) for anything representing persisted data (Song, Playlist, Settings).

## 10. Version Control

- See `git-and-versioning` conventions for commit message format and branching model.
- Commits should be scoped to a single logical change; avoid mixing formatting-only changes with functional changes in the same commit.

## 11. Performance

- Avoid rebuilding expensive widgets (e.g., the wave visualizer) more often than necessary — isolate it with appropriate widget boundaries and `RepaintBoundary` where applicable.
- Any file-system scanning (e.g., missing-file auto-detection) must run off the main isolate or be clearly chunked to avoid blocking the UI.
