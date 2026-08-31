import 'package:flutter/material.dart';

import '../../core/theme/app_gradients.dart';

/// A bold, rounded gradient button for primary actions (play, save,
/// create), in place of the flat Material default.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.icon,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: enabled ? AppGradients.primary(scheme) : null,
            color: enabled ? null : scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
            boxShadow: [
              if (enabled)
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              else
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: enabled ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
              ],
              DefaultTextStyle(
                style: TextStyle(
                  color: enabled ? scheme.onPrimary : scheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A [FloatingActionButton]-shaped button with a gradient fill, since the
/// stock widget only accepts a solid [Color].
class GradientFab extends StatelessWidget {
  const GradientFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.size = 56,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: Tooltip(
        message: tooltip ?? '',
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: enabled ? AppGradients.primary(scheme) : null,
              color: enabled ? null : scheme.surfaceContainerHighest,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.primary.withValues(alpha: 0.16)),
              boxShadow: [
                if (enabled)
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                else
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
              ],
            ),
            child: Icon(
              icon,
              size: size * 0.5,
              color: enabled ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
