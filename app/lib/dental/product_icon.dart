import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:identist_app/dental/dental_glyphs.dart';

/// A drawn dental glyph and a colour for a product.
///
/// Every catalogue row rendered the same generic box, so a rate card of a dozen
/// items read as one undifferentiated list and a clinic scanning for a crown
/// had to read every line.
///
/// A photo when the seller has added one, and a glyph when they have not.
///
/// The photo travels as base64 on the product record, the same way clinic logos
/// and clinical images already do. **Never a remote URL**: a CDN fetch on a
/// catalogue row would put back the dependency the font and CanvasKit work
/// removed, and a product picture is not worth a screen that cannot render
/// offline. Material icons ship in the binary and cost nothing to draw, so the
/// fallback is free.
///
/// Matching is on words rather than an enum because the category is free text:
/// a supplier types "Restorative", a lab has "Ceramic & All-Ceramic", and
/// neither is a fixed vocabulary this could switch on.
class ProductIcon {
  const ProductIcon(this.glyph, this.color);

  final DentalGlyph glyph;
  final Color color;

  static const _fallback = ProductIcon(DentalGlyph.box, Color(0xFF64748B));

  /// The best match for [category], falling back to a neutral box.
  ///
  /// [name] is consulted too, because a category is often generic ("General")
  /// while the product name is not ("Zirconia Crown").
  static ProductIcon forProduct({String category = '', String name = ''}) {
    final haystack = '$category $name'.toLowerCase();

    bool has(List<String> words) => words.any(haystack.contains);

    if (has(['implant', 'abutment'])) {
      return const ProductIcon(DentalGlyph.implant, Color(0xFF06B6D4));
    }
    if (has(['aligner', 'ortho', 'bracket', 'retainer'])) {
      return const ProductIcon(DentalGlyph.aligner, Color(0xFFEC4899));
    }
    if (has(['denture', 'removable', 'partial'])) {
      return const ProductIcon(DentalGlyph.denture, Color(0xFFF59E0B));
    }
    if (has(['guide', '3d print', 'surgical guide'])) {
      return const ProductIcon(DentalGlyph.tray, Color(0xFF8B5CF6));
    }
    if (has([
      'crown',
      'bridge',
      'zirconia',
      'emax',
      'e-max',
      'ceramic',
      'pfm',
      'veneer',
    ])) {
      return const ProductIcon(DentalGlyph.tooth, Color(0xFF00F2FE));
    }
    if (has(['endo', 'root canal', 'rotary', 'file', 'gutta'])) {
      return const ProductIcon(DentalGlyph.endoFile, Color(0xFFEF4444));
    }
    if (has(['restorative', 'composite', 'filling', 'bond', 'etch'])) {
      return const ProductIcon(DentalGlyph.syringe, Color(0xFF10B981));
    }
    if (has(['surgical', 'suture', 'scalpel', 'extraction', 'forcep'])) {
      return const ProductIcon(DentalGlyph.forceps, Color(0xFFF43F5E));
    }
    if (has(['perio', 'scaler', 'curette', 'ultrasonic'])) {
      return const ProductIcon(DentalGlyph.scaler, Color(0xFF3B82F6));
    }
    if (has(['impression', 'alginate', 'silicone', 'tray', 'model'])) {
      return const ProductIcon(DentalGlyph.tray, Color(0xFFA855F7));
    }
    if (has([
      'equipment',
      'machine',
      'chair',
      'handpiece',
      'motor',
      'mill',
      'scanner',
      'x-ray',
      'xray',
      'sensor',
    ])) {
      return const ProductIcon(DentalGlyph.handpiece, Color(0xFF0EA5E9));
    }
    if (has(['bib', 'drape', 'apron', 'napkin', 'towel'])) {
      return const ProductIcon(DentalGlyph.bib, Color(0xFF14B8A6));
    }
    if (has(['glove', 'mask', 'disposable', 'consumable', 'cotton', 'gauze'])) {
      return const ProductIcon(DentalGlyph.glove, Color(0xFF14B8A6));
    }
    if (has(['medicine', 'pharma', 'drug', 'anesth', 'gel', 'paste'])) {
      return const ProductIcon(DentalGlyph.medicament, Color(0xFFFB7185));
    }
    return _fallback;
  }

  /// A rounded tile: the seller's photo if there is one, else the glyph.
  ///
  /// [imageBase64] may carry a `data:` prefix or be bare — both shapes occur in
  /// stored records — and a value that will not decode falls through to the
  /// icon rather than showing a broken tile.
  Widget tile({double size = 44, double iconSize = 22, String? imageBase64}) {
    final radius = BorderRadius.circular(size * 0.27);
    final photo = _decode(imageBase64);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: radius,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: photo != null
          ? Image.memory(
              photo,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) =>
                  DentalGlyphIcon(glyph, color: color, size: iconSize),
            )
          : DentalGlyphIcon(glyph, color: color, size: iconSize),
    );
  }

  /// Bytes for an inline image, or null when [raw] is a URL or unusable.
  ///
  /// Public so a screen can decide between an inline photo and a network one
  /// without duplicating the base64 handling.
  static Uint8List? decodeInline(String? raw) => _decode(raw);

  static Uint8List? _decode(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return null;
    try {
      if (v.startsWith('http://') || v.startsWith('https://')) return null;
      final payload = v.contains(',') ? v.split(',').last : v;
      if (payload.length < 32) return null;
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }
}
