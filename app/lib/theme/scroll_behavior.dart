import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// How every scrollable in the app behaves, decided once.
///
/// This used to be decided 112 times, inline, by whoever wrote the widget:
/// 91 `BouncingScrollPhysics` against 21 `ClampingScrollPhysics`, split along
/// no line anyone could state. The patient-detail tabs had been converted and
/// nothing else had, so scrolling changed feel as a clinician moved between a
/// patient's tabs and the rest of the app.
///
/// The split that was intended is the one the login screen already wrote by
/// hand — `isDesktop ? Clamping : Bouncing`:
///
///   * **Pointer platforms** get [ClampingScrollPhysics]. A mouse wheel sends
///     discrete deltas, and bouncing spends them on an elastic curve, so the
///     list keeps drifting after the wheel has stopped. Clamping stops when
///     the input stops, which is what a wheel user expects.
///   * **Touch platforms** get [BouncingScrollPhysics], the native iOS/Android
///     feel, where the rubber band at the end of a list is the platform's own
///     signal that there is nothing more to see.
///
/// Individual widgets may still override `physics:` — `NeverScrollableScrollPhysics`
/// on a nested list is a structural choice, not a feel one, and is untouched.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  /// Trackpad and mouse drag are included so a desktop browser can drag-scroll
  /// a horizontal chip row that has no visible scrollbar.
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.android:
        return const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        );
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        );
    }
  }
}
