import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 24,
    this.color,
    this.borderColor,
    this.shadowColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppThemePalette>();
    final theme = Theme.of(context);
    final resolvedColor =
        (color ??
                palette?.glassSurfaceColor ??
                theme.colorScheme.surfaceContainerHighest)
            .withValues(
              alpha: (palette?.surfaceOpacity ?? 0.8).clamp(0.0, 1.0),
            );
    final resolvedBorder =
        borderColor ?? palette?.borderColor ?? theme.colorScheme.outlineVariant;
    final resolvedShadow =
        shadowColor ?? palette?.shadowColor ?? theme.colorScheme.shadow;
    final blurSigma = palette?.blurSigma ?? 18.0;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: resolvedColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: resolvedBorder),
        boxShadow: [
          BoxShadow(
            color: resolvedShadow.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
