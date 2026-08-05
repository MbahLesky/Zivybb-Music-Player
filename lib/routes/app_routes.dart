/// Named route identifiers, used as [RouteSettings.name] for navigation
/// observability (analytics, debugging) even though V1 navigates via
/// direct [MaterialPageRoute] pushes.
abstract final class AppRoutes {
  static const library = '/library';
  static const nowPlaying = '/now-playing';
  static const queue = '/now-playing/queue';
  static const fullScreenVisualizer = '/now-playing/visualizer';
  static const settings = '/settings';
}
