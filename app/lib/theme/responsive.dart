import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Allows forcing mobile preview mode across desktop testing viewports.
/// Defaults to false so the normal wide screen desktop UI is displayed by default.
/// Users can toggle Mobile Test View anytime using the Mobile Test button in the top demo bar.
final mobilePreviewOverrideProvider = StateProvider<bool>((ref) => false);

/// Shared mobile / tablet / desktop breakpoints used across dashboards,
/// dialogs, and picker shells. Prefer these over ad-hoc magic numbers.
class Responsive {
  Responsive._();

  /// Phone / small tablet — drawer + bottom nav territory.
  static const double mobile = 900;

  /// Narrow phone (legacy SE / small Android).
  static const double phoneNarrow = 360;

  /// Compact phone (most modern devices).
  static const double phone = 430;

  /// Tablet / small laptop split for two-column forms.
  static const double tablet = 760;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= mobile;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= phone;

  static bool isNarrowPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= phoneNarrow;

  static bool isTabletOrNarrower(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;

  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// Preferred dialog width clamped to the viewport (minus side inset).
  static double dialogWidth(
    BuildContext context,
    double preferred, {
    double horizontalInset = 24,
  }) {
    final max = MediaQuery.sizeOf(context).width - horizontalInset;
    if (!max.isFinite || max <= 0) return preferred;
    return math.min(preferred, max);
  }

  /// Full-bleed dialogs on phone; floating on larger screens.
  static EdgeInsets dialogInset(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w <= mobile) {
      return w <= phone
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
  }

  static double dialogRadius(BuildContext context) =>
      MediaQuery.sizeOf(context).width <= mobile ? 0 : 20;
}
