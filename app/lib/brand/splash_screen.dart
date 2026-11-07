import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:identist_app/brand/brand_marks.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.message});

  /// What the app is doing while the
  /// splash stays up — "Signing you in…" while an Apple or Google answer is
  /// checked — in place of the lock line; the lock line when null.
  final String? message;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// The words under the bar while the app opens.
const String splashUnlockingText = 'Unlocking your encrypted workspace…';

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// The tile's glide from the middle to its place (phones only).
  late final AnimationController _glide;

  /// The bar's moving light.
  late final AnimationController _bar;

  static bool get _fromMiddle =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _glide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      value: _fromMiddle ? 0 : 1,
    );
    if (_fromMiddle) _glide.forward();
    _bar = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _glide.dispose();
    _bar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const tile = 132.0;
    return Scaffold(
      backgroundColor: brandNavy,
      body: LayoutBuilder(
        builder: (context, box) {
          final h = box.maxHeight;
          final top = (h * 0.155).clamp(
            MediaQuery.paddingOf(context).top + 24,
            h,
          );
          final middle = (h - tile) / 2;
          return AnimatedBuilder(
            animation: Listenable.merge([_glide, _bar]),
            builder: (context, _) {
              final t = Curves.easeOutCubic.transform(_glide.value);
              final tileTop = middle + (top - middle) * t;
              final words = Curves.easeOut.transform(
                ((_glide.value - 0.35) / 0.65).clamp(0.0, 1.0),
              );
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: tileTop - 150,
                    height: 430,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [Color(0xFF16294A), brandNavy],
                          radius: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: tileTop,
                    child: const Center(child: AppIconTile(size: tile)),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    top: top + tile + 28,
                    child: Opacity(
                      opacity: words,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 460),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: BrandTitle(size: 34),
                              ),
                              const SizedBox(height: 14),
                              const PlatformPill(),
                              const SizedBox(height: 36),
                              _LoadingBar(phase: _bar.value),
                              const SizedBox(height: 26),
                              if (widget.message != null)
                                Text(
                                  widget.message!,
                                  key: const ValueKey('splash_message'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFCBD5E1),
                                  ),
                                )
                              else
                                const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    key: ValueKey('splash_unlocking'),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.lock_rounded,
                                        color: Color(0xFF22C55E),
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        splashUnlockingText,
                                        style: TextStyle(
                                          color: Color(0xFFCBD5E1),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: MediaQuery.paddingOf(context).bottom + 40,
                    child: Opacity(
                      opacity: words,
                      child: const Center(child: MadeInIndiaLine()),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// The glowing cyan bar: a light that runs along a soft track.
class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.phase});

  final double phase;

  @override
  Widget build(BuildContext context) {
    const width = 150.0;
    const light = 70.0;
    final left = -light + (width + light) * phase;
    return Container(
      width: width,
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0x1FFFFFFF),
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: left,
              top: 0,
              bottom: 0,
              width: light,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                  gradient: LinearGradient(
                    colors: [
                      Color(0x0022D3EE),
                      Color(0xFF22D3EE),
                      Color(0xFF3B82F6),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(color: Color(0x9922D3EE), blurRadius: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
