import 'package:flutter/material.dart';
import 'package:identist_app/panels/popup_look.dart';
import 'package:identist_app/theme/glass_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;

  /// How strongly the backdrop is blurred. 0 paints the same glass panel
  /// without a BackdropFilter — use it for a panel that sits on another
  /// panel or a plain page (rows in a list), where the fill is already 80–96 %
  /// opaque and a blur changes nothing you can see. See [GlassTheme.glassBlur].
  final double blurSigma;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;
  final Color? borderColor;
  final AlignmentGeometry? alignment;

  const GlassContainer({
    super.key,
    required this.child,
    this.radius = 16.0,
    this.blurSigma = 15.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
    this.borderColor,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final look = UiPopupScope.maybeOf(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      decoration: look == null
          ? GlassTheme.glassDecoration(
              isDark: isDark,
              radius: radius,
              customBorderColor: borderColor,
            )
          : BoxDecoration(
              color: look.card,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: borderColor ?? look.line, width: 1.2),
            ),
      child: GlassTheme.glassBlur(
        blurSigma: blurSigma,
        radius: radius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class GlowDivider extends StatelessWidget {
  const GlowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).primaryColor;

    return Container(
      height: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.05),
            accent.withValues(alpha: 0.4),
            accent.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.2 : 0.15),
            blurRadius: 4.0,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }
}
