import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:identist_app/assets.dart';

/// The app icon's navy.
const Color brandNavy = Color(0xFF0B1329);

/// The app icon as a tile: navy, rounded, a thin blue edge, a soft cyan glow
/// and the tooth at 76 % (the icon's size S4).
class AppIconTile extends StatelessWidget {
  const AppIconTile({super.key, this.size = 132, this.glow = true});

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: brandNavy,
      borderRadius: BorderRadius.circular(size * 0.27),
      border: Border.all(
        color: const Color(0xFF2A4A7A),
        width: math.max(1, size * 0.012),
      ),
      boxShadow: glow
          ? [
              BoxShadow(
                color: const Color(0x5522D3EE),
                blurRadius: size * 0.35,
                spreadRadius: -size * 0.03,
              ),
            ]
          : null,
    ),
    child: Image.asset(
      UiAssets.logo,
      package: kUiPackage,
      width: size * 0.76,
      height: size * 0.76,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => Icon(
        Icons.medical_services_rounded,
        color: const Color(0xFF00E5FF),
        size: size * 0.5,
      ),
    ),
  );
}

/// "iDentist.Live" in the brand style (Plan §2): "iDentist" heavy white
/// (dark navy on light pages), ".Live" in the cyan gradient, and the tick.
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, this.size = 32, this.dark = true});

  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      letterSpacing: -0.5,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: dark
                ? const [Colors.white, Color(0xFFE2E8F0)]
                : const [Color(0xFF0F172A), Color(0xFF334155)],
          ).createShader(b),
          child: Text('iDentist', style: style),
        ),
        ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: dark
                ? const [Color(0xFF00F2FE), Color(0xFF38BDF8)]
                : const [Color(0xFF06B6D4), Color(0xFF0EA5E9)],
          ).createShader(b),
          child: Text('.Live', style: style),
        ),
        SizedBox(width: size * 0.14),
        Icon(
          Icons.verified_rounded,
          size: size * 0.68,
          color: dark ? const Color(0xFF00F2FE) : const Color(0xFF0EA5E9),
        ),
      ],
    );
  }
}

/// "• PREMIUM DENTIST PLATFORM" in spaced capitals with the splash's
/// cyan-to-violet gradient, inside a soft glass pill.
class PlatformPill extends StatelessWidget {
  const PlatformPill({super.key, this.dark = true});

  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
    decoration: BoxDecoration(
      color: (dark ? Colors.white : const Color(0xFF0F172A)).withValues(
        alpha: dark ? 0.06 : 0.04,
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: const Color(0x3338BDF8)),
      boxShadow: const [BoxShadow(color: Color(0x2238BDF8), blurRadius: 18)],
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF00F2FE),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0xFF00F2FE), blurRadius: 8)],
            ),
          ),
          const SizedBox(width: 9),
          ShaderMask(
            shaderCallback: (b) => LinearGradient(
              colors: dark
                  ? const [
                      Color(0xFF38BDF8),
                      Color(0xFF818CF8),
                      Color(0xFFC084FC),
                    ]
                  : const [
                      Color(0xFF0284C7),
                      Color(0xFF6366F1),
                      Color(0xFF9333EA),
                    ],
            ).createShader(b),
            child: const Text(
              'PREMIUM DENTIST PLATFORM',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// India's flag: saffron, white, green, and the 24-spoke Ashoka Chakra.
class IndiaFlag extends StatelessWidget {
  const IndiaFlag({super.key, this.width = 24});

  final double width;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'India',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(width * 0.1),
      child: CustomPaint(
        size: Size(width, width * 2 / 3),
        painter: _FlagPainter(),
      ),
    ),
  );
}

class _FlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height / 3;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, h),
      Paint()..color = const Color(0xFFFF9933),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, h, size.width, h),
      Paint()..color = Colors.white,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 2 * h, size.width, h),
      Paint()..color = const Color(0xFF138808),
    );
    final c = Offset(size.width / 2, size.height / 2);
    final r = h * 0.44;
    const navy = Color(0xFF000080);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = navy
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12,
    );
    final spoke = Paint()
      ..color = navy
      ..strokeWidth = r * 0.06;
    for (var i = 0; i < 24; i++) {
      final a = i * math.pi * 2 / 24;
      canvas.drawLine(c, c + Offset(r * math.cos(a), r * math.sin(a)), spoke);
    }
    canvas.drawCircle(c, r * 0.16, Paint()..color = navy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "Made in India 🇮🇳 Made for India".
class MadeInIndiaLine extends StatelessWidget {
  const MadeInIndiaLine({super.key, this.dark = true});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: dark ? Colors.white : const Color(0xFF0F172A),
      fontSize: 14.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Made in India', style: style),
          const SizedBox(width: 10),
          const IndiaFlag(),
          const SizedBox(width: 10),
          Text('Made for India', style: style),
        ],
      ),
    );
  }
}
