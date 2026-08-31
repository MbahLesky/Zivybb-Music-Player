import 'package:flutter/material.dart';

/// An icon action for [GradientAppBar] with a scaffold-colored circular
/// backing, so it reads clearly against the gradient instead of blending
/// into it (icons with no backing were low-contrast against
/// [AppGradients.primary]).
class AppBarIconAction extends StatelessWidget {
  const AppBarIconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.iconColor,
  });

  /// Usually an [Icon], but can be any widget (e.g. a [Badge]-wrapped icon
  /// or a loading spinner standing in for one).
  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      icon: icon,
      tooltip: tooltip,
      color: iconColor ?? scheme.primary,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: scheme.surface,
        shape: const CircleBorder(),
      ),
    );
  }
}
