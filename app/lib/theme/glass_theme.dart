import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:identist_app/theme/colors.dart';

class GlassTheme {
  /// The bundled brand face. Declared in pubspec.yaml, shipped in the binary.
  ///
  /// This was `GoogleFonts.outfitTextTheme(...)`, which resolves a font by
  /// downloading it from fonts.gstatic.com on first use. With no bundled copy
  /// and no `allowRuntimeFetching = false` guard, every glyph in the app
  /// depended on reaching Google. When the request failed — offline, a slow
  /// link, a firewall, a fresh browser profile — google_fonts still returned a
  /// TextStyle naming a family the engine could not resolve, and CanvasKit
  /// renders an unresolved family as nothing at all: no tofu, no error, just
  /// absent text and absent icons over a UI whose boxes and gradients painted
  /// perfectly. That is the blank screen users were reporting.
  static const String fontFamily = 'Outfit';

  /// Consulted for glyphs Outfit does not carry.
  ///
  /// Outfit ships 360 codepoints and the rupee sign is not among them, so ₹ —
  /// which appears on nearly every screen in this app — had no glyph in the
  /// brand face. It looked fine only because CanvasKit quietly downloads a
  /// fallback font from gstatic when it meets a character it cannot draw.
  /// Bundling Noto Sans covers the gap locally and closes that last silent
  /// network dependency in the render path.
  ///
  /// `NotoSansGujarati` is second because Noto Sans does not carry Gujarati
  /// either — it has Latin, Greek, Cyrillic and Devanagari and stops there. A
  /// Gujarati patient name therefore reached NO font in the bundle and drew as
  /// boxes. Order matters: Outfit first for the brand, NotoSans for ₹ and
  /// Devanagari, Gujarati last, since a fallback list is consulted in order and
  /// only for glyphs the earlier faces cannot draw.
  static const List<String> fontFamilyFallback = [
    'NotoSans',
    'NotoSansGujarati',
  ];

  /// Applies the bundled family to a Material text theme.
  ///
  /// `TextTheme.apply` does not carry a fallback list, so each style is mapped
  /// explicitly. Without this the fallback is dropped and ₹ goes back to
  /// hitting the network.
  static TextTheme _appTextTheme(TextTheme base) {
    TextStyle? f(TextStyle? s) => s?.copyWith(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
    );
    return base.copyWith(
      displayLarge: f(base.displayLarge),
      displayMedium: f(base.displayMedium),
      displaySmall: f(base.displaySmall),
      headlineLarge: f(base.headlineLarge),
      headlineMedium: f(base.headlineMedium),
      headlineSmall: f(base.headlineSmall),
      titleLarge: f(base.titleLarge),
      titleMedium: f(base.titleMedium),
      titleSmall: f(base.titleSmall),
      bodyLarge: f(base.bodyLarge),
      bodyMedium: f(base.bodyMedium),
      bodySmall: f(base.bodySmall),
      labelLarge: f(base.labelLarge),
      labelMedium: f(base.labelMedium),
      labelSmall: f(base.labelSmall),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.darkPrimaryGlow,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimaryGlow,
        secondary: AppColors.darkSecondaryGlow,
        surface: AppColors.darkSurface,
      ),
      textTheme: _appTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: const TextStyle(
          color: AppColors.darkTextPrimary,
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
        ),
        bodyMedium: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      scaffoldBackgroundColor: AppColors.lightBg,
      primaryColor: AppColors.lightPrimaryGlow,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimaryGlow,
        secondary: AppColors.lightSecondaryGlow,
        surface: AppColors.lightSurface,
      ),
      textTheme: _appTextTheme(ThemeData.light().textTheme).copyWith(
        bodyLarge: const TextStyle(
          color: AppColors.lightTextPrimary,
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
        ),
        bodyMedium: const TextStyle(
          color: AppColors.lightTextSecondary,
          fontFamily: fontFamily,
          fontFamilyFallback: fontFamilyFallback,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE2E8F0),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.lightPrimaryGlow,
            width: 1.6,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }

  static BoxDecoration glassDecoration({
    required bool isDark,
    double radius = 16,
    Color? customBorderColor,
  }) {
    return BoxDecoration(
      gradient: isDark
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0F172A).withValues(alpha: 0.8),
                const Color(0xFF090D1A).withValues(alpha: 0.95),
              ],
            )
          : LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.96),
                const Color(0xFFF0F9FF).withValues(alpha: 0.88),
              ],
            ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color:
            customBorderColor ??
            (isDark
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFFCBD5E1)),
        width: 1.2,
      ),
      boxShadow: isDark
          ? [
              BoxShadow(
                color: const Color(0xFF00F2FE).withValues(alpha: 0.06),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ]
          : [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.07),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: const Color(0xFF64748B).withValues(alpha: 0.04),
                blurRadius: 1,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
    );
  }

  /// Clips [child] to the glass shape and blurs what lies behind it.
  ///
  /// A [blurSigma] of 0 (or less) skips the [BackdropFilter]. A blur of 0 is
  /// invisible anyway, but the filter still costs a save layer and a read of
  /// the whole backdrop on every frame — the dearest thing a scrolling list can
  /// paint on a low-end phone. The web has always skipped it.
  static Widget glassBlur({
    required Widget child,
    double blurSigma = 15.0,
    double radius = 16.0,
  }) {
    if (kIsWeb || blurSigma <= 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: child,
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: child,
      ),
    );
  }
}
