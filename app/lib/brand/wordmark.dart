import 'package:flutter/material.dart';

/// Standardized iDentist.Live dual-tone brand title with optional verified badge.
///
/// Always formats:
/// - "iDentist" in white / high-contrast bold typography (`Outfit` / sans-serif)
/// - ".Live" in vibrant cyan (`#00F2FE` / `#38BDF8`)
/// - Optional cyan verified badge icon `Icons.verified_rounded`
class IDentistLiveTitle extends StatelessWidget {
  final double fontSize;
  final bool isDark;
  final bool showBadge;
  final double? badgeSize;
  final Color? liveColor;
  final Color? dentistColor;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;

  const IDentistLiveTitle({
    super.key,
    this.fontSize = 24.0,
    this.isDark = true,
    this.showBadge = true,
    this.badgeSize,
    this.liveColor,
    this.dentistColor,
    this.mainAxisSize = MainAxisSize.min,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLiveColor = liveColor ?? const Color(0xFF00F2FE);
    final effectiveDentistColor =
        dentistColor ?? (isDark ? Colors.white : const Color(0xFF0F172A));
    final effectiveBadgeSize = badgeSize ?? (fontSize * 0.75);

    return Row(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          "iDentist",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: effectiveDentistColor,
            letterSpacing: -0.5,
            fontFamily: 'Outfit',
          ),
        ),
        Text(
          ".Live",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: effectiveLiveColor,
            letterSpacing: -0.5,
            fontFamily: 'Outfit',
          ),
        ),
        if (showBadge) ...[
          SizedBox(width: fontSize * 0.16),
          Icon(
            Icons.verified_rounded,
            size: effectiveBadgeSize,
            color: effectiveLiveColor,
          ),
        ],
      ],
    );
  }
}
