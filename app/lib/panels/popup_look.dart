import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// The colours a pop-up is drawn in.
@immutable
class UiPopupLook {
  const UiPopupLook({
    required this.dark,
    required this.surface,
    required this.card,
    required this.field,
    required this.line,
    required this.accent,
    required this.accent2,
    required this.onAccent,
    required this.text,
    required this.soft,
    required this.faint,
    this.blur = 0,
  });

  final bool dark;

  /// The glass blur behind pop-ups, slightly see-through and matching the
  /// theme; 0 = none (a slow device, or outside the new screens).
  final double blur;

  /// The pop-up's own fill (opaque).
  final Color surface;

  /// A card or panel inside a pop-up.
  final Color card;

  /// Inputs and quiet buttons.
  final Color field;
  final Color line;

  /// The person's colour and its partner, and words on them.
  final Color accent;
  final Color accent2;
  final Color onAccent;
  final Color text;
  final Color soft;
  final Color faint;

  LinearGradient get accentGradient =>
      LinearGradient(colors: [accent, accent2]);

  /// The pop-up's edge: a soft line of the person's colour.
  Color get edge => accent.withValues(alpha: dark ? 0.38 : 0.30);

  @override
  bool operator ==(Object other) =>
      other is UiPopupLook &&
      other.dark == dark &&
      other.surface == surface &&
      other.card == card &&
      other.field == field &&
      other.line == line &&
      other.accent == accent &&
      other.accent2 == accent2 &&
      other.onAccent == onAccent &&
      other.text == text &&
      other.soft == soft &&
      other.faint == faint &&
      other.blur == blur;

  @override
  int get hashCode => Object.hash(
    dark,
    surface,
    card,
    field,
    line,
    accent,
    accent2,
    onAccent,
    text,
    soft,
    faint,
    blur,
  );
}

/// Puts [look] in force below it and in every pop-up opened from below it.
class UiPopupScope extends InheritedTheme {
  const UiPopupScope({super.key, required this.look, required super.child});

  final UiPopupLook look;

  static UiPopupLook? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<UiPopupScope>()?.look;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      UiPopupScope(look: look, child: child);

  @override
  bool updateShouldNotify(UiPopupScope old) => old.look != look;
}

/// A pop-up's fill: the new design's inside the app's new screens, else
/// [today] (the colour the pop-up was drawn in before).
Color uiPopupSurface(BuildContext context, Color today) =>
    UiPopupScope.maybeOf(context)?.surface ?? today;

/// A card or panel inside a pop-up, likewise.
Color uiPopupCard(BuildContext context, Color today) =>
    UiPopupScope.maybeOf(context)?.card ?? today;

/// A field's fill, likewise.
Color uiPopupField(BuildContext context, Color today) =>
    UiPopupScope.maybeOf(context)?.field ?? today;

/// The round coloured icon at the top of a pop-up (the new design's orb).
/// [danger] draws it in red (delete, erase, sign out everywhere).
class UiDialogIcon extends StatelessWidget {
  const UiDialogIcon(this.icon, {super.key, this.color, this.danger = false});

  final IconData icon;
  final Color? color;
  final bool danger;

  static const Color _red = Color(0xFFF43F5E);

  @override
  Widget build(BuildContext context) {
    final look = UiPopupScope.maybeOf(context);
    final isDark =
        look?.dark ?? Theme.of(context).brightness == Brightness.dark;
    final c = danger
        ? _red
        : (color ?? look?.accent ?? Theme.of(context).colorScheme.primary);
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            c.withValues(alpha: isDark ? 0.30 : 0.20),
            c.withValues(alpha: isDark ? 0.10 : 0.06),
          ],
        ),
        border: Border.all(color: c.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: isDark ? 0.35 : 0.20),
            blurRadius: 18,
            spreadRadius: -4,
          ),
        ],
      ),
      child: Icon(icon, color: c, size: 26),
    );
  }
}

/// The new design's pop-up title: the orb, the title and an optional line
/// under it. Used in [UiDialogHeader], and on its own where a pop-up keeps
/// its own bar (a back arrow and actions in an app bar, a coloured banner).
class UiDialogTitle extends StatelessWidget {
  const UiDialogTitle({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.danger = false,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final bool danger;

  /// Words on a coloured banner (white); null follows the pop-up look.
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final look = UiPopupScope.maybeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text =
        textColor ??
        look?.text ??
        (isDark ? Colors.white : const Color(0xFF0F172A));
    final soft =
        textColor?.withValues(alpha: 0.8) ??
        look?.soft ??
        (isDark ? Colors.white70 : Colors.black54);
    return Row(
      children: [
        Transform.scale(
          scale: 0.8,
          child: UiDialogIcon(icon, color: color, danger: danger),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: text,
                  letterSpacing: -0.2,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty)
                Text(subtitle!, style: TextStyle(fontSize: 12.5, color: soft)),
            ],
          ),
        ),
      ],
    );
  }
}

/// The new design's pop-up header for pop-ups that draw their own window:
/// the orb, the title (and a line under it) and a close button.
class UiDialogHeader extends StatelessWidget {
  const UiDialogHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    this.danger = false,
    this.onClose,
    this.canClose = true,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final bool danger;

  /// Close; null pops the pop-up.
  final VoidCallback? onClose;

  /// False greys the close button out (while the pop-up is saving), and a
  /// click outside the pop-up (or Back) waits too.
  final bool canClose;

  /// Words on a coloured banner (white); null follows the pop-up look.
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final look = UiPopupScope.maybeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final soft =
        textColor?.withValues(alpha: 0.8) ??
        look?.soft ??
        (isDark ? Colors.white70 : Colors.black54);
    return PopScope(
      canPop: canClose,
      child: Row(
        children: [
          Expanded(
            child: UiDialogTitle(
              icon: icon,
              title: title,
              subtitle: subtitle,
              color: color,
              danger: danger,
              textColor: textColor,
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: canClose
                ? (onClose ?? () => Navigator.of(context).maybePop())
                : null,
            icon: Icon(Icons.close_rounded, color: soft),
          ),
        ],
      ),
    );
  }
}

/// A drop-in for [Dialog]: inside the app's new screens it draws the new
/// design's window (rounded 24, the person's colour along the edge and in a
/// thin bar across the top, a soft glow) whatever shape and fill the pop-up
/// asked for; elsewhere it is exactly today's [Dialog]. A see-through dialog
/// (an X-ray viewer, the camera) keeps its own look everywhere.
class UiDialog extends StatelessWidget {
  const UiDialog({
    super.key,
    this.child,
    this.backgroundColor,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetAnimationCurve = Curves.decelerate,
    this.insetPadding,
    this.clipBehavior,
    this.shape,
    this.alignment,
  });

  final Widget? child;
  final Color? backgroundColor;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final Duration insetAnimationDuration;
  final Curve insetAnimationCurve;
  final EdgeInsets? insetPadding;
  final Clip? clipBehavior;
  final ShapeBorder? shape;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    final look = UiPopupScope.maybeOf(context);
    if (look == null || backgroundColor == Colors.transparent) {
      final seeThrough = look != null;
      return Dialog(
        backgroundColor: backgroundColor,
        elevation: seeThrough ? (elevation ?? 0) : elevation,
        shadowColor: seeThrough
            ? (shadowColor ?? Colors.transparent)
            : shadowColor,
        surfaceTintColor: surfaceTintColor,
        insetAnimationDuration: insetAnimationDuration,
        insetAnimationCurve: insetAnimationCurve,
        insetPadding: insetPadding,
        clipBehavior: clipBehavior,
        shape: seeThrough ? (shape ?? const RoundedRectangleBorder()) : shape,
        alignment: alignment,
        child: child,
      );
    }
    if (MediaQuery.sizeOf(context).shortestSide < 600) {
      return Dialog(
        backgroundColor: look.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shadowColor: Colors.black.withValues(alpha: 0.5),
        insetAnimationDuration: insetAnimationDuration,
        insetAnimationCurve: insetAnimationCurve,
        insetPadding: const EdgeInsets.only(top: 40),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          side: BorderSide(color: look.edge),
        ),
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 2),
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: look.faint.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (child != null) Flexible(child: child!),
            ],
          ),
        ),
      );
    }
    return Dialog(
      backgroundColor: look.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: look.accent.withValues(alpha: look.dark ? 0.45 : 0.25),
      insetAnimationDuration: insetAnimationDuration,
      insetAnimationCurve: insetAnimationCurve,
      insetPadding: insetPadding,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: look.edge),
      ),
      alignment: alignment,
      child: Stack(
        children: [
          ?child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 3,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(gradient: look.accentGradient),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The page behind a glass dialog, blurred (taps still reach the veil, so a
/// tap outside closes the dialog as before).
class UiGlassBackdrop extends StatelessWidget {
  const UiGlassBackdrop({super.key, required this.sigma, required this.child});

  final double sigma;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned.fill(
        child: IgnorePointer(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: const SizedBox.expand(),
          ),
        ),
      ),
      child,
    ],
  );
}

/// A sheet's own glass: the page behind the sheet blurred, inside its
/// rounded top.
class UiGlassSheetBackdrop extends StatelessWidget {
  const UiGlassSheetBackdrop({
    super.key,
    required this.sigma,
    required this.child,
    this.radius = 26,
  });

  final double sigma;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: child,
    ),
  );
}

/// [showDialog] as glass in the new screens.
Future<T?> showGlassDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
  TraversalEdgeBehavior? traversalEdgeBehavior,
  bool fullscreenDialog = false,
  bool? requestFocus,
  AnimationStyle? animationStyle,
}) {
  final blur = UiPopupScope.maybeOf(context)?.blur ?? 0;
  return showDialog<T>(
    context: context,
    builder: blur > 0 && !fullscreenDialog
        ? (c) => UiGlassBackdrop(sigma: blur, child: builder(c))
        : builder,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useSafeArea: useSafeArea,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
    traversalEdgeBehavior: traversalEdgeBehavior,
    fullscreenDialog: fullscreenDialog,
    requestFocus: requestFocus,
    animationStyle: animationStyle,
  );
}

/// [showModalBottomSheet] as a glass sheet in the new screens.
Future<T?> showGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
  String? barrierLabel,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  Color? barrierColor,
  bool isScrollControlled = false,
  double scrollControlDisabledMaxHeightRatio = 9.0 / 16.0,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
  bool? showDragHandle,
  bool useSafeArea = false,
  RouteSettings? routeSettings,
  AnimationController? transitionAnimationController,
  Offset? anchorPoint,
  AnimationStyle? sheetAnimationStyle,
  bool? requestFocus,
}) {
  final blur = UiPopupScope.maybeOf(context)?.blur ?? 0;
  return showModalBottomSheet<T>(
    context: context,
    builder: blur > 0
        ? (c) => UiGlassSheetBackdrop(sigma: blur, child: builder(c))
        : builder,
    backgroundColor: backgroundColor,
    barrierLabel: barrierLabel,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    barrierColor: barrierColor,
    isScrollControlled: isScrollControlled,
    scrollControlDisabledMaxHeightRatio: scrollControlDisabledMaxHeightRatio,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    showDragHandle: showDragHandle,
    useSafeArea: useSafeArea,
    routeSettings: routeSettings,
    transitionAnimationController: transitionAnimationController,
    anchorPoint: anchorPoint,
    sheetAnimationStyle: sheetAnimationStyle,
    requestFocus: requestFocus,
  );
}
