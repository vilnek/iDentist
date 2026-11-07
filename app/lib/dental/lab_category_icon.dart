import 'package:flutter/material.dart';
import 'package:identist_app/dental/lab_categories.dart';
import 'package:identist_app/assets.dart';

/// Renders a restoration category's picture for a given [LabWorkCategory]
/// or category name: the category's square photo at every size, rounded, with a thin edge in its colour; the
/// vector glyph only when asked ([preferVector]) or when the picture cannot
/// load.
class LabCategoryIcon extends StatelessWidget {
  final dynamic category; // LabWorkCategory or String?
  final double size;
  final bool showBackground;
  final bool? preferVector;
  final String? tooltip;

  const LabCategoryIcon({
    super.key,
    required this.category,
    this.size = 24.0,
    this.showBackground = false,
    this.preferVector,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final LabWorkCategory? resolved = category is LabWorkCategory
        ? category as LabWorkCategory
        : LabWorkCategory.find(category?.toString());

    final accent = resolved?.accentColor ?? const Color(0xFF6366F1);
    final vectorGlyph = resolved?.icon ?? Icons.biotech_rounded;
    final useVector = preferVector ?? false;

    Widget iconWidget;
    if (resolved != null && !useVector) {
      final radius = BorderRadius.circular(size * 0.24);
      iconWidget = Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: radius,
          color: accent.withValues(alpha: 0.12),
          border: Border.all(
            color: accent.withValues(alpha: 0.45),
            width: size < 28 ? 0.8 : 1.2,
          ),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Image.asset(
            resolved.iconAsset,
            package: kUiPackage,
            width: size,
            height: size,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            cacheWidth: (size * 3).round().clamp(48, 256),
            errorBuilder: (ctx, err, stack) =>
                Icon(vectorGlyph, size: size * 0.6, color: accent),
          ),
        ),
      );
    } else {
      iconWidget = Icon(vectorGlyph, size: size, color: accent);
    }

    if (showBackground && resolved != null && useVector) {
      iconWidget = Container(
        width: size + 10,
        height: size + 10,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(size * 0.35),
          border: Border.all(color: accent.withValues(alpha: 0.32), width: 1),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.12),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Icon(vectorGlyph, size: size * 0.85, color: accent),
        ),
      );
    }

    if (tooltip != null || resolved != null) {
      final tipText = tooltip ?? resolved?.name ?? 'Dental Lab Restoration';
      return Tooltip(message: tipText, child: iconWidget);
    }

    return iconWidget;
  }
}

/// A modern, glassmorphic visual pill badge displaying a razor-sharp vector icon
/// and the standardized dental category name.
class LabCategoryBadge extends StatelessWidget {
  final dynamic category; // LabWorkCategory or String?
  final double iconSize;
  final double fontSize;
  final bool isDark;
  final VoidCallback? onTap;

  const LabCategoryBadge({
    super.key,
    required this.category,
    this.iconSize = 14.0,
    this.fontSize = 11.0,
    this.isDark = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final LabWorkCategory? resolved = category is LabWorkCategory
        ? category as LabWorkCategory
        : LabWorkCategory.find(category?.toString());

    final displayName = resolved?.name ?? category?.toString() ?? 'Lab Work';
    final accent = resolved?.accentColor ?? const Color(0xFF6366F1);

    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: isDark ? 0.22 : 0.12),
            accent.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent.withValues(alpha: isDark ? 0.42 : 0.28),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.16 : 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LabCategoryIcon(
            category: resolved ?? category,
            size: iconSize,
            preferVector: true,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              displayName,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white.withValues(alpha: 0.95) : accent,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: badge,
      );
    }

    return badge;
  }
}
