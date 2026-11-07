import 'package:flutter/material.dart';

/// Interactive hover card that elevates, scales slightly, and highlights
/// border when hovered on desktop or web, providing smooth micro-animations.
class InteractiveHoverCard extends StatefulWidget {
  const InteractiveHoverCard({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.hoverScale = 1.015,
    this.hoverElevation = 6.0,
    this.defaultElevation = 0.0,
    this.borderColor,
    this.hoverBorderColor,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final double borderRadius;
  final double hoverScale;
  final double hoverElevation;
  final double defaultElevation;
  final Color? borderColor;
  final Color? hoverBorderColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  State<InteractiveHoverCard> createState() => _InteractiveHoverCardState();
}

class _InteractiveHoverCardState extends State<InteractiveHoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = _isHovered
        ? (widget.hoverBorderColor ??
              Theme.of(context).primaryColor.withValues(alpha: 0.5))
        : (widget.borderColor ?? Colors.transparent);

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: effectiveBorderColor, width: 1.2),
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color:
                      (widget.hoverBorderColor ??
                              Theme.of(context).primaryColor)
                          .withValues(alpha: 0.15),
                  blurRadius: widget.hoverElevation * 3,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ]
            : (widget.defaultElevation > 0
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: widget.defaultElevation * 2,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : []),
      ),
      child: widget.child,
    );

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? widget.hoverScale : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: card,
        ),
      ),
    );
  }
}
