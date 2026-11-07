import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Dental instruments and materials, drawn.
///
/// Material ships no dental iconography at all — no tooth, no handpiece, no
/// tray — so the catalogue was reaching for the nearest generic glyph and a
/// box of extraction forceps was rendering as a first-aid kit. A dentist reads
/// these shapes faster than the label, and a wrong shape is worse than none.
///
/// Drawn as paths rather than pulled from an icon service on purpose. The app
/// is offline-first, so a runtime fetch is out; and the free dental icon sets
/// (Flaticon, Freepik, Icons8) want attribution or a licence fee that a
/// shipped product should not take on. Vectors in the repo have no licence,
/// no network and no asset-loading step, and they scale and recolour cleanly.
///
/// Every path is authored in a 24x24 box and scaled to the requested size, the
/// same convention Material icons use.
enum DentalGlyph {
  tooth,
  implant,
  denture,
  aligner,
  tray,
  handpiece,
  bur,
  scaler,
  forceps,
  endoFile,
  syringe,
  glove,
  bib,
  medicament,
  box,
}

/// One drawing instruction: a path plus how to paint it.
class GlyphStroke {
  const GlyphStroke(
    this.path, {
    this.fill = true,
    this.width = 1.6,
    this.erase = false,
  });

  final Path path;
  final bool fill;
  final double width;

  /// Cuts the shape back out of what has already been drawn, which is how the
  /// bottle gets its cross and the arch its gaps between teeth.
  final bool erase;
}

/// Builds the paths for each glyph, in a 24x24 space.
class DentalGlyphPaths {
  const DentalGlyphPaths._();

  static List<GlyphStroke> of(DentalGlyph glyph) {
    switch (glyph) {
      case DentalGlyph.tooth:
        return [GlyphStroke(_tooth())];
      case DentalGlyph.implant:
        return _implant();
      case DentalGlyph.denture:
        return _denture();
      case DentalGlyph.aligner:
        return _aligner();
      case DentalGlyph.tray:
        return _tray();
      case DentalGlyph.handpiece:
        return _handpiece();
      case DentalGlyph.bur:
        return _bur();
      case DentalGlyph.scaler:
        return _scaler();
      case DentalGlyph.forceps:
        return _forceps();
      case DentalGlyph.endoFile:
        return _endoFile();
      case DentalGlyph.syringe:
        return _syringe();
      case DentalGlyph.glove:
        return [GlyphStroke(_glove())];
      case DentalGlyph.bib:
        return [GlyphStroke(_bib())];
      case DentalGlyph.medicament:
        return _medicament();
      case DentalGlyph.box:
        return _box();
    }
  }

  /// The classic two-rooted tooth. Stands for crowns, veneers and ceramics.
  static Path _tooth() {
    return Path()
      ..moveTo(12, 2.2)
      ..cubicTo(9.2, 2.2, 8.0, 3.4, 6.2, 3.4)
      ..cubicTo(4.0, 3.4, 2.6, 5.2, 2.6, 7.8)
      ..cubicTo(2.6, 11.2, 4.1, 13.8, 5.1, 16.2)
      ..cubicTo(5.9, 18.2, 6.2, 22.0, 8.0, 22.0)
      ..cubicTo(9.7, 22.0, 9.9, 19.3, 10.3, 17.3)
      ..cubicTo(10.6, 15.8, 11.1, 14.9, 12.0, 14.9)
      ..cubicTo(12.9, 14.9, 13.4, 15.8, 13.7, 17.3)
      ..cubicTo(14.1, 19.3, 14.3, 22.0, 16.0, 22.0)
      ..cubicTo(17.8, 22.0, 18.1, 18.2, 18.9, 16.2)
      ..cubicTo(19.9, 13.8, 21.4, 11.2, 21.4, 7.8)
      ..cubicTo(21.4, 5.2, 20.0, 3.4, 17.8, 3.4)
      ..cubicTo(16.0, 3.4, 14.8, 2.2, 12.0, 2.2)
      ..close();
  }

  /// A fixture: platform on top, tapered threaded body below.
  static List<GlyphStroke> _implant() {
    final body = Path()
      ..moveTo(8.6, 6.4)
      ..lineTo(15.4, 6.4)
      ..lineTo(13.2, 18.6)
      ..lineTo(12.0, 21.6)
      ..lineTo(10.8, 18.6)
      ..close();
    final platform = Path()
      ..addRRect(
        RRect.fromLTRBR(9.0, 2.4, 15.0, 6.0, const Radius.circular(1)),
      );
    final threads = Path();
    const rows = [
      [9.1, 9.2, 14.9],
      [9.5, 12.0, 14.5],
      [9.9, 14.8, 14.1],
      [10.3, 17.4, 13.7],
    ];
    for (final r in rows) {
      threads
        ..moveTo(r[0], r[1])
        ..lineTo(r[2], r[1]);
    }
    return [
      GlyphStroke(platform),
      GlyphStroke(body),
      GlyphStroke(threads, fill: false, width: 1.0),
    ];
  }

  /// An arch of teeth, cut apart so they read as separate crowns.
  ///
  /// The teeth were drawn as circles on top of the gum and merged into it —
  /// the result was a plain arch, indistinguishable from the impression tray.
  /// Cutting gaps through the band guarantees they stay separate at any size.
  static List<GlyphStroke> _denture() {
    final arch = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(2.6, 20.4)
      ..lineTo(2.6, 13.4)
      ..cubicTo(2.6, 7.0, 6.8, 3.2, 12.0, 3.2)
      ..cubicTo(17.2, 3.2, 21.4, 7.0, 21.4, 13.4)
      ..lineTo(21.4, 20.4)
      ..lineTo(16.4, 20.4)
      ..lineTo(16.4, 13.4)
      ..cubicTo(16.4, 10.0, 14.6, 8.2, 12.0, 8.2)
      ..cubicTo(9.4, 8.2, 7.6, 10.0, 7.6, 13.4)
      ..lineTo(7.6, 20.4)
      ..close();
    final gaps = Path();
    for (var i = 1; i < 8; i++) {
      final angle = math.pi * (i / 8.0);
      final dx = -math.cos(angle);
      final dy = -math.sin(angle);
      gaps
        ..moveTo(12.0 + dx * 4.4, 13.6 + dy * 4.4)
        ..lineTo(12.0 + dx * 10.6, 13.6 + dy * 10.6);
    }
    return [
      GlyphStroke(arch),
      GlyphStroke(gaps, fill: false, width: 1.15, erase: true),
    ];
  }

  /// An archwire threaded through brackets.
  static List<GlyphStroke> _aligner() {
    final wire = Path()
      ..moveTo(3.0, 17.0)
      ..cubicTo(3.0, 8.6, 7.4, 5.2, 12.0, 5.2)
      ..cubicTo(16.6, 5.2, 21.0, 8.6, 21.0, 17.0);
    final brackets = Path();
    const spots = [
      [4.1, 14.2],
      [6.6, 8.6],
      [12.0, 6.4],
      [17.4, 8.6],
      [19.9, 14.2],
    ];
    for (final s in spots) {
      brackets.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(s[0], s[1]), width: 3.4, height: 3.4),
          const Radius.circular(0.9),
        ),
      );
    }
    return [GlyphStroke(wire, fill: false, width: 1.7), GlyphStroke(brackets)];
  }

  /// An impression tray from above: a horseshoe rim with a front handle.
  ///
  /// The handle is what separates this from the denture arch at a glance, so
  /// it is drawn long and square rather than tucked into the rim.
  static List<GlyphStroke> _tray() {
    final rim = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(1.8, 21.6)
      ..lineTo(1.8, 13.6)
      ..cubicTo(1.8, 8.4, 6.2, 5.0, 12.0, 5.0)
      ..cubicTo(17.8, 5.0, 22.2, 8.4, 22.2, 13.6)
      ..lineTo(22.2, 21.6)
      ..lineTo(17.6, 21.6)
      ..lineTo(17.6, 13.6)
      ..cubicTo(17.6, 10.8, 15.2, 9.2, 12.0, 9.2)
      ..cubicTo(8.8, 9.2, 6.4, 10.8, 6.4, 13.6)
      ..lineTo(6.4, 21.6)
      ..close();
    final handle = Path()
      ..addRRect(
        RRect.fromLTRBR(10.2, 0.6, 13.8, 6.6, const Radius.circular(1.1)),
      );
    return [GlyphStroke(handle), GlyphStroke(rim)];
  }

  /// An airotor: angled body, round head, bur in the chuck.
  static List<GlyphStroke> _handpiece() {
    final body = Path()
      ..moveTo(2.4, 18.6)
      ..lineTo(6.0, 22.0)
      ..lineTo(15.0, 11.8)
      ..lineTo(11.2, 8.4)
      ..close();
    final head = Path()
      ..addOval(Rect.fromCircle(center: const Offset(16.8, 8.2), radius: 4.0));
    final bur = Path()
      ..addRRect(
        RRect.fromLTRBR(15.9, 0.4, 17.7, 4.6, const Radius.circular(0.6)),
      );
    final chuck = Path()
      ..addOval(Rect.fromCircle(center: const Offset(16.8, 8.2), radius: 1.5));
    return [
      GlyphStroke(bur),
      GlyphStroke(body),
      GlyphStroke(head),
      GlyphStroke(chuck, erase: true),
    ];
  }

  /// A long shank with a small flame head — a bur, not a spoon.
  static List<GlyphStroke> _bur() {
    final shank = Path()
      ..addRRect(
        RRect.fromLTRBR(10.9, 1.2, 13.1, 15.4, const Radius.circular(0.9)),
      );
    final head = Path()
      ..moveTo(12.0, 14.6)
      ..cubicTo(14.9, 16.0, 15.4, 18.4, 14.2, 20.6)
      ..cubicTo(13.5, 21.9, 12.6, 22.8, 12.0, 22.8)
      ..cubicTo(11.4, 22.8, 10.5, 21.9, 9.8, 20.6)
      ..cubicTo(8.6, 18.4, 9.1, 16.0, 12.0, 14.6)
      ..close();
    final notches = Path()
      ..addRect(const Rect.fromLTRB(10.5, 3.2, 13.5, 4.1))
      ..addRect(const Rect.fromLTRB(10.5, 5.4, 13.5, 6.3));
    return [
      GlyphStroke(shank),
      GlyphStroke(head),
      GlyphStroke(notches, erase: true),
    ];
  }

  /// A sickle scaler: knurled handle, shank, curved point.
  static List<GlyphStroke> _scaler() {
    final handle = Path()
      ..addRRect(
        RRect.fromLTRBR(4.2, 15.2, 12.6, 20.4, const Radius.circular(2.4)),
      );
    final shank = Path()
      ..moveTo(12.0, 15.6)
      ..cubicTo(15.0, 13.4, 16.6, 10.6, 17.4, 7.2);
    final tip = Path()
      ..moveTo(17.4, 7.2)
      ..cubicTo(18.6, 4.6, 19.4, 3.0, 19.9, 1.8)
      ..cubicTo(19.0, 3.4, 17.6, 5.0, 16.0, 6.0);
    final grip = Path();
    for (var i = 0; i < 3; i++) {
      final x = 6.0 + i * 1.9;
      grip
        ..moveTo(x, 16.4)
        ..lineTo(x, 19.2);
    }
    return [
      GlyphStroke(handle),
      GlyphStroke(shank, fill: false, width: 1.7),
      GlyphStroke(tip),
      GlyphStroke(grip, fill: false, width: 0.9),
    ];
  }

  /// Extraction forceps: hinged handles, beaks at the working end.
  static List<GlyphStroke> _forceps() {
    final left = Path()
      ..moveTo(9.4, 22.2)
      ..cubicTo(7.4, 18.0, 7.0, 15.0, 9.2, 12.6)
      ..lineTo(6.2, 6.6)
      ..cubicTo(5.6, 5.4, 6.0, 4.2, 7.2, 3.8)
      ..cubicTo(8.0, 3.5, 8.8, 3.9, 9.2, 4.8)
      ..lineTo(11.4, 11.0)
      ..lineTo(11.4, 12.4)
      ..cubicTo(10.2, 15.2, 10.6, 18.2, 11.6, 22.2)
      ..close();
    final right = Path()
      ..moveTo(14.6, 22.2)
      ..cubicTo(16.6, 18.0, 17.0, 15.0, 14.8, 12.6)
      ..lineTo(17.8, 6.6)
      ..cubicTo(18.4, 5.4, 18.0, 4.2, 16.8, 3.8)
      ..cubicTo(16.0, 3.5, 15.2, 3.9, 14.8, 4.8)
      ..lineTo(12.6, 11.0)
      ..lineTo(12.6, 12.4)
      ..cubicTo(13.8, 15.2, 13.4, 18.2, 12.4, 22.2)
      ..close();
    final hinge = Path()
      ..addOval(Rect.fromCircle(center: const Offset(12.0, 13.4), radius: 1.5));
    return [GlyphStroke(left), GlyphStroke(right), GlyphStroke(hinge)];
  }

  /// A rotary file: a ribbed grip over a long, very thin tapered shaft.
  ///
  /// Drawn deliberately unlike the implant, which is a short fat threaded
  /// body — at 22px the two were the same screw.
  static List<GlyphStroke> _endoFile() {
    final grip = Path()
      ..addRRect(
        RRect.fromLTRBR(8.2, 1.2, 15.8, 8.4, const Radius.circular(2.0)),
      );
    final ribs = Path();
    for (var i = 0; i < 3; i++) {
      final y = 3.2 + i * 1.8;
      ribs
        ..moveTo(9.6, y)
        ..lineTo(14.4, y);
    }
    final shaft = Path()
      ..moveTo(11.2, 8.4)
      ..lineTo(12.8, 8.4)
      ..lineTo(12.25, 20.0)
      ..lineTo(12.0, 23.0)
      ..lineTo(11.75, 20.0)
      ..close();
    final flutes = Path();
    for (var i = 0; i < 6; i++) {
      final y = 10.0 + i * 2.0;
      flutes
        ..moveTo(10.6, y)
        ..lineTo(13.4, y + 1.5);
    }
    return [
      GlyphStroke(grip),
      GlyphStroke(ribs, fill: false, width: 0.9, erase: true),
      GlyphStroke(shaft),
      GlyphStroke(flutes, fill: false, width: 0.75),
    ];
  }

  /// A composite compule gun: barrel, plunger, angled nozzle.
  ///
  /// Sits low in the box on purpose — with the barrel centred the nozzle threw
  /// the whole shape into the top half and the tile looked bottom-empty.
  static List<GlyphStroke> _syringe() {
    final barrel = Path()
      ..addRRect(
        RRect.fromLTRBR(6.0, 11.6, 15.2, 17.4, const Radius.circular(1.7)),
      );
    final plunger = Path()
      ..moveTo(2.0, 13.5)
      ..lineTo(6.0, 13.5)
      ..lineTo(6.0, 15.5)
      ..lineTo(2.0, 15.5)
      ..close();
    final flange = Path()
      ..addRRect(
        RRect.fromLTRBR(1.0, 11.2, 2.7, 17.8, const Radius.circular(0.7)),
      );
    final nozzle = Path()
      ..moveTo(15.2, 13.0)
      ..lineTo(19.0, 8.4)
      ..lineTo(20.9, 6.0)
      ..lineTo(22.2, 7.1)
      ..lineTo(20.3, 9.5)
      ..lineTo(16.5, 15.4)
      ..lineTo(15.2, 15.4)
      ..close();
    final seam = Path()
      ..moveTo(11.0, 12.4)
      ..lineTo(11.0, 16.6);
    return [
      GlyphStroke(flange),
      GlyphStroke(plunger),
      GlyphStroke(barrel),
      GlyphStroke(nozzle),
      GlyphStroke(seam, fill: false, width: 0.9, erase: true),
    ];
  }

  /// An examination glove: four fingers, thumb, cuff.
  static Path _glove() {
    return Path()
      ..moveTo(6.0, 22.2)
      ..lineTo(6.0, 13.6)
      ..cubicTo(4.2, 13.0, 3.0, 11.6, 3.0, 10.0)
      ..cubicTo(3.0, 8.6, 4.0, 7.8, 5.0, 8.2)
      ..cubicTo(5.6, 8.4, 6.0, 9.0, 6.4, 9.8)
      ..lineTo(7.0, 9.8)
      ..lineTo(7.0, 3.6)
      ..cubicTo(7.0, 2.6, 7.7, 2.0, 8.5, 2.0)
      ..cubicTo(9.3, 2.0, 10.0, 2.6, 10.0, 3.6)
      ..lineTo(10.0, 8.6)
      ..lineTo(11.0, 8.6)
      ..lineTo(11.0, 2.6)
      ..cubicTo(11.0, 1.6, 11.7, 1.0, 12.5, 1.0)
      ..cubicTo(13.3, 1.0, 14.0, 1.6, 14.0, 2.6)
      ..lineTo(14.0, 8.6)
      ..lineTo(15.0, 8.6)
      ..lineTo(15.0, 3.2)
      ..cubicTo(15.0, 2.2, 15.7, 1.6, 16.5, 1.6)
      ..cubicTo(17.3, 1.6, 18.0, 2.2, 18.0, 3.2)
      ..lineTo(18.0, 9.4)
      ..cubicTo(18.0, 9.4, 18.4, 8.0, 19.4, 8.0)
      ..cubicTo(20.4, 8.0, 21.0, 8.8, 21.0, 10.0)
      ..lineTo(21.0, 13.4)
      ..cubicTo(21.0, 17.0, 19.6, 20.0, 18.0, 22.2)
      ..close();
  }

  /// A patient bib with the neck cut out.
  static Path _bib() {
    return Path()
      ..moveTo(8.2, 3.4)
      ..cubicTo(8.9, 5.6, 10.3, 6.6, 12.0, 6.6)
      ..cubicTo(13.7, 6.6, 15.1, 5.6, 15.8, 3.4)
      ..lineTo(19.2, 4.6)
      ..cubicTo(20.6, 5.1, 21.2, 6.2, 21.0, 7.6)
      ..lineTo(19.4, 20.0)
      ..cubicTo(19.2, 21.4, 18.4, 22.0, 17.0, 22.0)
      ..lineTo(7.0, 22.0)
      ..cubicTo(5.6, 22.0, 4.8, 21.4, 4.6, 20.0)
      ..lineTo(3.0, 7.6)
      ..cubicTo(2.8, 6.2, 3.4, 5.1, 4.8, 4.6)
      ..close();
  }

  /// A medicament bottle with a dropper cap.
  static List<GlyphStroke> _medicament() {
    final cap = Path()
      ..addRRect(
        RRect.fromLTRBR(9.4, 1.6, 14.6, 4.6, const Radius.circular(0.9)),
      );
    final neck = Path()
      ..addRRect(
        RRect.fromLTRBR(10.4, 4.6, 13.6, 7.0, const Radius.circular(0.4)),
      );
    final body = Path()
      ..moveTo(8.2, 7.0)
      ..lineTo(15.8, 7.0)
      ..cubicTo(17.6, 8.4, 18.4, 10.2, 18.4, 12.4)
      ..lineTo(18.4, 19.4)
      ..cubicTo(18.4, 21.2, 17.4, 22.2, 15.6, 22.2)
      ..lineTo(8.4, 22.2)
      ..cubicTo(6.6, 22.2, 5.6, 21.2, 5.6, 19.4)
      ..lineTo(5.6, 12.4)
      ..cubicTo(5.6, 10.2, 6.4, 8.4, 8.2, 7.0)
      ..close();
    final cross = Path()
      ..addRect(const Rect.fromLTRB(11.1, 12.2, 12.9, 19.0))
      ..addRect(const Rect.fromLTRB(8.6, 14.7, 15.4, 16.5));
    return [
      GlyphStroke(cap),
      GlyphStroke(neck),
      GlyphStroke(body),
      GlyphStroke(cross, erase: true),
    ];
  }

  /// A shipping carton, for anything uncategorised.
  ///
  /// Outlined rather than solid: filled, the seam lines were the same colour
  /// as the body and the whole thing collapsed into a hexagon.
  static List<GlyphStroke> _box() {
    final carton = Path()
      ..moveTo(3.2, 7.4)
      ..lineTo(12.0, 2.6)
      ..lineTo(20.8, 7.4)
      ..lineTo(20.8, 16.6)
      ..lineTo(12.0, 21.4)
      ..lineTo(3.2, 16.6)
      ..close();
    final seam = Path()
      ..moveTo(3.2, 7.4)
      ..lineTo(12.0, 12.2)
      ..lineTo(20.8, 7.4)
      ..moveTo(12.0, 12.2)
      ..lineTo(12.0, 21.4);
    return [
      GlyphStroke(carton, fill: false, width: 1.8),
      GlyphStroke(seam, fill: false, width: 1.5),
    ];
  }
}

/// Paints one [DentalGlyph] to fill the given size.
class DentalGlyphPainter extends CustomPainter {
  const DentalGlyphPainter(this.glyph, this.color);

  final DentalGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 24.0;
    canvas.save();
    canvas.translate(
      (size.width - 24 * scale) / 2,
      (size.height - 24 * scale) / 2,
    );
    canvas.scale(scale);
    canvas.saveLayer(const Rect.fromLTWH(0, 0, 24, 24), Paint());

    for (final stroke in DentalGlyphPaths.of(glyph)) {
      final paint = Paint()
        ..color = color
        ..isAntiAlias = true;
      if (stroke.erase) paint.blendMode = BlendMode.clear;
      if (stroke.fill) {
        paint.style = PaintingStyle.fill;
      } else {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke.width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
      }
      canvas.drawPath(stroke.path, paint);
    }
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(DentalGlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}

/// A [DentalGlyph] as a widget, sized like an [Icon].
class DentalGlyphIcon extends StatelessWidget {
  const DentalGlyphIcon(
    this.glyph, {
    super.key,
    this.size = 24,
    this.color = const Color(0xFF64748B),
  });

  final DentalGlyph glyph;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: DentalGlyphPainter(glyph, color),
          isComplex: false,
        ),
      ),
    );
  }
}
