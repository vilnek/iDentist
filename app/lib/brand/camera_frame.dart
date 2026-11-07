import 'package:flutter/material.dart';
import 'package:identist_app/panels/popup_look.dart';

const _blue = Color(0xFF3B82F6);
const _rose = Color(0xFFF43F5E);
const _red = Color(0xFFEF4444);

/// The framed camera card. [child] is the live view, a message or a photo.
class UiCameraFrame extends StatelessWidget {
  const UiCameraFrame({
    super.key,
    required this.child,
    this.live = false,
    this.status,
    this.faceGuide = false,
    this.error = false,
    this.marks = true,
    this.aspectRatio = 4 / 3,
    this.topRight,
    this.tint,
  });

  final Widget child;

  /// The camera is on: LIVE shows at the top.
  final bool live;

  /// A short line at the foot ("Looking for a face…"); null shows none.
  final String? status;

  /// The face oval (Face ID windows).
  final bool faceGuide;

  /// Something went wrong: a red edge, no marks.
  final bool error;

  /// The four corner marks.
  final bool marks;

  final double aspectRatio;

  /// A small control in the top-right corner (a camera picker).
  final Widget? topRight;

  /// Colours the edge and the face guide instead of the person's colour (a
  /// face check's result: green, amber, red).
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final accent =
        tint ??
        UiPopupScope.maybeOf(context)?.accent ??
        const Color(0xFF22D3EE);
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: error ? const [_red, _red] : [accent, tint ?? _blue],
          ),
          boxShadow: [
            BoxShadow(
              color: (error ? _red : accent).withValues(alpha: 0.22),
              blurRadius: 22,
              spreadRadius: -6,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Color(0xFF0B1220)),
              child,
              if (faceGuide && live && !error)
                IgnorePointer(
                  child: Align(
                    alignment: const Alignment(0, -0.1),
                    child: FractionallySizedBox(
                      widthFactor: 0.42,
                      heightFactor: 0.74,
                      child: CustomPaint(painter: _FaceGuide(accent)),
                    ),
                  ),
                ),
              if (marks && live && !error)
                const IgnorePointer(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18, 42, 18, 18),
                    child: CustomPaint(painter: _CornerMarks()),
                  ),
                ),
              if (live && !error)
                const Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  child: Center(child: UiCameraChip('LIVE', dot: _rose)),
                ),
              if (status != null && !error)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Center(child: UiCameraChip(status!, dot: accent)),
                ),
              if (topRight != null)
                Positioned(top: 8, right: 8, child: topRight!),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small dark chip over the camera: a coloured dot and a few words.
class UiCameraChip extends StatelessWidget {
  const UiCameraChip(this.text, {super.key, this.dot = _rose});

  final String text;
  final Color dot;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

/// The round dark control over the camera (a camera picker's face).
class UiCameraButton extends StatelessWidget {
  const UiCameraButton({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.black.withValues(alpha: 0.5),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
    ),
    child: Icon(icon, color: Colors.white, size: 18),
  );
}

/// A message inside the frame (camera starting, no camera, an error) with an
/// optional action under it.
class UiCameraMessage extends StatelessWidget {
  const UiCameraMessage({
    super.key,
    required this.icon,
    required this.text,
    this.error = false,
    this.busy = false,
    this.action,
  });

  final IconData icon;
  final String text;
  final bool error;

  /// A spinner instead of the icon.
  final bool busy;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFF0B1220).withValues(alpha: 0.88),
    padding: const EdgeInsets.all(20),
    alignment: Alignment.center,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (busy)
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        else
          Icon(
            icon,
            color: error ? const Color(0xFFFCA5A5) : Colors.white70,
            size: 34,
          ),
        const SizedBox(height: 12),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: error ? const Color(0xFFFCA5A5) : Colors.white70,
          ),
        ),
        if (action != null) ...[const SizedBox(height: 14), action!],
      ],
    ),
  );
}

class _FaceGuide extends CustomPainter {
  const _FaceGuide(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Offset.zero & size,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = color.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(_FaceGuide old) => old.color != color;
}

class _CornerMarks extends CustomPainter {
  const _CornerMarks();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.85);
    const l = 22.0;
    final w = size.width, h = size.height;
    for (final (x, y, dx, dy) in [
      (0.0, 0.0, 1.0, 1.0),
      (w, 0.0, -1.0, 1.0),
      (0.0, h, 1.0, -1.0),
      (w, h, -1.0, -1.0),
    ]) {
      canvas.drawLine(Offset(x, y), Offset(x + l * dx, y), paint);
      canvas.drawLine(Offset(x, y), Offset(x, y + l * dy), paint);
    }
  }

  @override
  bool shouldRepaint(_CornerMarks old) => false;
}
