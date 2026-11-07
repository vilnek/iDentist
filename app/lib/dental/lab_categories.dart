import 'package:flutter/material.dart';

/// Represents a standardized Dental Lab Work Category shared between
/// Dental Clinic Practice Management (Procedures & Treatment Catalog) and
/// Dental Lab Ecosystems (Product Directory, Rate Card & Case Intake).
class LabWorkCategory {
  final String id;
  final String code;
  final String name;
  final String description;
  final String indications;
  final int defaultTurnaroundDays;
  final String iconAsset;
  final Color accentColor;
  final IconData icon;

  const LabWorkCategory({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.indications,
    required this.defaultTurnaroundDays,
    required this.iconAsset,
    required this.accentColor,
    this.icon = Icons.biotech_rounded,
  });

  static const LabWorkCategory zirconia = LabWorkCategory(
    id: 'zirconia_crown',
    code: 'ZIRC',
    name: 'Zirconia Crown & Bridge',
    description:
        'High-strength 5Y-TZP multi-layer gradient zirconia with natural incisal translucency',
    indications:
        'Anterior & Posterior Crowns, 3-Unit Bridges, High-Load Molars',
    defaultTurnaroundDays: 4,
    iconAsset: 'assets/icons/lab_categories/lab_01_zirconia.jpg',
    accentColor: Color(0xFF6366F1), // Indigo
    icon: Icons.diamond_rounded,
  );

  static const LabWorkCategory golden = LabWorkCategory(
    id: 'golden_crown',
    code: 'GOLD',
    name: 'Golden Crown & Bridge',
    description:
        'High-noble Type IV gold alloy with mirror burnished finish and biocompatible margins',
    indications:
        'Posterior Molars, Low Clearance Bites, Conservative Tooth Preparations',
    defaultTurnaroundDays: 5,
    iconAsset: 'assets/icons/lab_categories/lab_02_gold.jpg',
    accentColor: Color(0xFFF59E0B), // Amber / Gold
    icon: Icons.workspace_premium_rounded,
  );

  static const LabWorkCategory ceramicPfm = LabWorkCategory(
    id: 'ceramic_pfm_crown',
    code: 'PFM',
    name: 'Ceramic PFM Crown & Bridge',
    description:
        'Porcelain fused to medical-grade Cobalt-Chromium with precision lingual metal collar',
    indications:
        'Single Crowns, Long-Span Bridges, Bruxism Wear with High Esthetics',
    defaultTurnaroundDays: 4,
    iconAsset: 'assets/icons/lab_categories/lab_03_pfm.jpg',
    accentColor: Color(0xFF0EA5E9), // Sky Blue
    icon: Icons.shield_rounded,
  );

  static const LabWorkCategory metal = LabWorkCategory(
    id: 'metal_crown',
    code: 'MET',
    name: 'Metal Crown & Bridge',
    description:
        'Medical-grade Cobalt-Chromium (Co-Cr) full metal casting with knife-edge margins',
    indications:
        'Posterior Molar Full Metal Caps, Heavy Bruxers, Minimal Reduction Cases',
    defaultTurnaroundDays: 3,
    iconAsset: 'assets/icons/lab_categories/lab_04_metal.jpg',
    accentColor: Color(0xFF64748B), // Slate / Metallic
    icon: Icons.precision_manufacturing_rounded,
  );

  static const LabWorkCategory monolithic = LabWorkCategory(
    id: 'monolithic_crown',
    code: 'MONO',
    name: 'Monolithic Crown & Bridge',
    description:
        'Full-contour lithium disilicate glass ceramic (IPS e.max CAD) for chameleon anterior esthetics',
    indications: 'Anterior Crowns, Inlays, Onlays, Cosmetic Single Units',
    defaultTurnaroundDays: 3,
    iconAsset: 'assets/icons/lab_categories/lab_05_monolithic.jpg',
    accentColor: Color(0xFF10B981), // Emerald
    icon: Icons.auto_awesome_rounded,
  );

  static const LabWorkCategory completeDenture = LabWorkCategory(
    id: 'complete_denture',
    code: 'CD',
    name: 'Complete Denture (CD)',
    description:
        'High-impact anatomical pink acrylic full maxillary/mandibular arch with cross-linked teeth',
    indications: 'Edentulous Maxilla/Mandible Full Arch Rehabilitation',
    defaultTurnaroundDays: 6,
    iconAsset: 'assets/icons/lab_categories/lab_06_complete_denture.jpg',
    accentColor: Color(0xFFEC4899), // Pink
    icon: Icons.view_agenda_rounded,
  );

  static const LabWorkCategory removablePartialDenture = LabWorkCategory(
    id: 'removable_partial_denture',
    code: 'RPD',
    name: 'Removable Partial Denture (RPD)',
    description:
        'Precision cast Co-Cr metal framework or flexible Valplast saddle with retentive clasps',
    indications: 'Partially Edentulous Kennedy Class I-IV Arches',
    defaultTurnaroundDays: 5,
    iconAsset: 'assets/icons/lab_categories/lab_07_partial_denture.jpg',
    accentColor: Color(0xFF8B5CF6), // Purple
    icon: Icons.architecture_rounded,
  );

  static const LabWorkCategory implantSupported = LabWorkCategory(
    id: 'implant_supported_crown',
    code: 'IMP',
    name: 'Implant Supported Abutments & Crowns',
    description:
        'Custom milled titanium or zirconia abutment with screw-retained ceramic restoration',
    indications:
        'Single Tooth Implant Restorations, Multi-Unit Implant Bridges',
    defaultTurnaroundDays: 5,
    iconAsset: 'assets/icons/lab_categories/lab_08_implant_crown.jpg',
    accentColor: Color(0xFF06B6D4), // Cyan
    icon: Icons.anchor_rounded,
  );

  static const LabWorkCategory fullArchImplant = LabWorkCategory(
    id: 'full_arch_implant',
    code: 'ARCH',
    name: 'Full Arch Implant Prosthetics',
    description:
        'All-on-4 / All-on-6 rigid titanium milled framework bar with monolithic hybrid bridge',
    indications:
        'Full Arch Fixed Implant Reconstruction, Severe Ridge Resorption',
    defaultTurnaroundDays: 7,
    iconAsset: 'assets/icons/lab_categories/lab_09_full_arch_implant.jpg',
    accentColor: Color(0xFF2563EB), // Blue
    icon: Icons.all_inclusive_rounded,
  );

  static const LabWorkCategory clearAligners = LabWorkCategory(
    id: 'clear_aligners',
    code: 'ALGN',
    name: 'Clear Aligners & Retainers',
    description:
        'Sequential thermoformed clear orthodontic aligners with scalloped gingival contours',
    indications: 'Mild to Moderate Malocclusion, Post-Orthodontic Retention',
    defaultTurnaroundDays: 5,
    iconAsset: 'assets/icons/lab_categories/lab_10_aligners.jpg',
    accentColor: Color(0xFF14B8A6), // Teal
    icon: Icons.waves_rounded,
  );

  static const LabWorkCategory nightGuards = LabWorkCategory(
    id: 'night_guards',
    code: 'NG',
    name: 'Night Guards & Occlusal Splints',
    description:
        'Dual-laminate thermoformed occlusal splint with flat contact plane and canine guidance',
    indications: 'Nocturnal Bruxism, Clenching, TMD Joint Protection',
    defaultTurnaroundDays: 3,
    iconAsset: 'assets/icons/lab_categories/lab_11_night_guard.jpg',
    accentColor: Color(0xFF3B82F6), // Blue
    icon: Icons.nightlight_round,
  );

  static const LabWorkCategory dentalVeneers = LabWorkCategory(
    id: 'dental_veneers',
    code: 'VNR',
    name: 'Dental Veneers, Inlays & Onlays',
    description:
        'Ultra-thin 0.3mm micro-etched feldspathic or e.max ceramic laminates for smile makeover',
    indications:
        'Diastema Closure, Discolored Anterior Teeth, Enamel Hypoplasia',
    defaultTurnaroundDays: 4,
    iconAsset: 'assets/icons/lab_categories/lab_12_veneers.jpg',
    accentColor: Color(0xFFF43F5E), // Rose
    icon: Icons.flare_rounded,
  );

  static const LabWorkCategory surgicalGuides = LabWorkCategory(
    id: 'surgical_guides',
    code: 'GUIDE',
    name: 'Surgical Guides & 3D Printed Models',
    description:
        'Biocompatible 3D printed resin stent with precision stainless steel drill guidance sleeves',
    indications:
        'CBCT Guided Implant Surgery, Bone Reduction Guides, Diagnostic Study Models',
    defaultTurnaroundDays: 2,
    iconAsset: 'assets/icons/lab_categories/lab_13_3d_models.jpg',
    accentColor: Color(0xFFD97706), // Amber
    icon: Icons.center_focus_strong_rounded,
  );

  static const LabWorkCategory temporaryProvisionals = LabWorkCategory(
    id: 'temporary_provisionals',
    code: 'TEMP',
    name: 'Temporary & Provisional Restorations',
    description:
        'CAD/CAM milled multi-layer PMMA long-term provisional crowns and 3-unit bridges',
    indications:
        'Implant Healing Phase, Full Mouth Rehab Mockups, Gingival Emergence Profiling',
    defaultTurnaroundDays: 2,
    iconAsset: 'assets/icons/lab_categories/lab_14_temporary.jpg',
    accentColor: Color(0xFF78716C), // Stone
    icon: Icons.hourglass_bottom_rounded,
  );

  static const LabWorkCategory orthodonticAppliances = LabWorkCategory(
    id: 'orthodontic_appliances',
    code: 'ORTHO',
    name: 'Orthodontic Appliances',
    description:
        'Custom wire-bending appliances with Jack-screws, Adams retention clasps, and space maintainers',
    indications:
        'Palatal Expansion, Space Maintenance, Habit Breaking Appliances',
    defaultTurnaroundDays: 4,
    iconAsset: 'assets/icons/lab_categories/lab_15_ortho.jpg',
    accentColor: Color(0xFFA855F7), // Purple
    icon: Icons.tune_rounded,
  );

  static const LabWorkCategory bleachingTrays = LabWorkCategory(
    id: 'bleaching_trays',
    code: 'TRAY',
    name: 'Bleaching & Custom Trays',
    description:
        'Soft flexible custom EVA whitening and fluoride trays with reservoir spaces',
    indications:
        'Home Whitening Kits, Fluoride Desensitizing Application, Custom Impression Trays',
    defaultTurnaroundDays: 2,
    iconAsset: 'assets/icons/lab_categories/lab_16_trays.jpg',
    accentColor: Color(0xFF0284C7), // Sky Blue
    icon: Icons.clean_hands_rounded,
  );

  /// Always shown last on every list — work that fits no other category.
  static const LabWorkCategory other = LabWorkCategory(
    id: 'other',
    code: 'OTHER',
    name: 'Other',
    description:
        'Any other laboratory work, described in the product name and notes',
    indications: 'Work that fits no other category',
    defaultTurnaroundDays: 5,
    iconAsset: 'assets/icons/lab_categories/lab_17_other.jpg',
    accentColor: Color(0xFF64748B), // Slate
    icon: Icons.more_horiz_rounded,
  );

  /// The 16 standardized lab work categories in logical clinical order, and
  /// Other last.
  static const List<LabWorkCategory> all = [
    zirconia,
    golden,
    ceramicPfm,
    metal,
    monolithic,
    completeDenture,
    removablePartialDenture,
    implantSupported,
    fullArchImplant,
    clearAligners,
    nightGuards,
    dentalVeneers,
    surgicalGuides,
    temporaryProvisionals,
    orthodonticAppliances,
    bleachingTrays,
    other,
  ];

  /// List of category display names.
  static List<String> get allNames => all.map((c) => c.name).toList();

  /// List of category codes.
  static List<String> get allCodes => all.map((c) => c.code).toList();

  /// Case-insensitive resolver that matches by name, ID, code, legacy category name,
  /// or hints found in an optional product title.
  static LabWorkCategory? find(String? query, {String? productName}) {
    final rawCombined = '${query ?? ''} ${productName ?? ''}'.trim();
    if (rawCombined.isEmpty) return null;
    final q = rawCombined.toLowerCase();

    for (final cat in all) {
      if (cat.id.toLowerCase() == q ||
          cat.name.toLowerCase() == q ||
          cat.code.toLowerCase() == q) {
        return cat;
      }
    }

    if (q.contains('veneer') ||
        q.contains('laminate') ||
        q.contains('inlay') ||
        q.contains('onlay') ||
        q.contains('vnr')) {
      return dentalVeneers;
    }

    if (q.contains('monolithic') ||
        q.contains('e.max') ||
        q.contains('emax') ||
        q.contains('disilicate') ||
        q.contains('all-ceramic') ||
        q.contains('all ceramic') ||
        q.contains('mono')) {
      return monolithic;
    }

    if (q.contains('zirconia') ||
        q.contains('zircon') ||
        q.contains('zerconia') ||
        q.contains('zirc') ||
        q.contains('3y-tzp') ||
        q.contains('5y-tzp')) {
      return zirconia;
    }

    if (q.contains('gold') ||
        q.contains('golden') ||
        q.contains('type iv') ||
        q.contains('noble')) {
      return golden;
    }

    if (q.contains('pfm') ||
        q.contains('porcelain fused') ||
        (q.contains('ceramic') &&
            !q.contains('lithium') &&
            !q.contains('max'))) {
      return ceramicPfm;
    }

    if (q.contains('metal crown') ||
        q.contains('cast metal') ||
        q.contains('cocr') ||
        (q.contains('metal') && !q.contains('pfm'))) {
      return metal;
    }

    if (q.contains('full arch') ||
        q.contains('all-on-4') ||
        q.contains('all-on-6') ||
        q.contains('hybrid bridge') ||
        q.contains('arch')) {
      return fullArchImplant;
    }

    if (q.contains('implant') ||
        q.contains('abutment') ||
        q.contains('ti-base') ||
        q.contains('tibase')) {
      return implantSupported;
    }

    if (q.contains('complete denture') ||
        q.contains('full denture') ||
        q == 'cd' ||
        q.contains('bps')) {
      return completeDenture;
    }

    if (q.contains('partial denture') ||
        q.contains('rpd') ||
        q.contains('valplast') ||
        q.contains('cast partial') ||
        q.contains('removable')) {
      return removablePartialDenture;
    }

    if (q.contains('aligner') ||
        q.contains('retainer') ||
        q.contains('invisalign') ||
        q.contains('algn')) {
      return clearAligners;
    }

    if (q.contains('night guard') ||
        q.contains('splint') ||
        q.contains('bruxism') ||
        q.contains('occlusal guard') ||
        q.contains('ng')) {
      return nightGuards;
    }

    if (q.contains('surgical guide') ||
        q.contains('3d print') ||
        q.contains('stent') ||
        q.contains('model') ||
        q.contains('guide')) {
      return surgicalGuides;
    }

    if (q.contains('temporary') ||
        q.contains('provisional') ||
        q.contains('pmma') ||
        q.contains('temp')) {
      return temporaryProvisionals;
    }

    if (q.contains('orthodontic') ||
        q.contains('ortho') ||
        q.contains('expansion') ||
        q.contains('space maintainer')) {
      return orthodonticAppliances;
    }

    if (q.contains('bleach') || q.contains('whitening') || q.contains('tray')) {
      return bleachingTrays;
    }

    return null;
  }
}
