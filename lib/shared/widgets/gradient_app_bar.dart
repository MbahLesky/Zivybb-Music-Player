import 'package:flutter/material.dart';

import '../../core/theme/app_gradients.dart';

/// An [AppBar] drop-in with a gradient background derived from the current
/// theme, used across every screen for a consistent, bolder look.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
  });

  final Widget title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppBar(
      title: title,
      actions: actions,
      bottom: bottom,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: scheme.onPrimary,
      iconTheme: IconThemeData(color: scheme.onPrimary),
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(gradient: AppGradients.primary(scheme)),
      ),
    );
  }
}
