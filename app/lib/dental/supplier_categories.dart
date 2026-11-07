import 'package:flutter/material.dart';
import 'package:identist_app/assets.dart';

class SupplierProductCategory {
  const SupplierProductCategory(this.name, this.file, this.icon, this.keywords);

  final String name;

  /// The picture's file in `assets/icons/supplier_categories/`.
  final String file;
  final IconData icon;

  /// Words in an older free-typed category or a product name that mean this
  /// category.
  final List<String> keywords;

  String get asset => '${UiAssets.supplierCategoryIconsDir}$file';

  static const List<SupplierProductCategory> all =
      [
        SupplierProductCategory(
          'Restorative',
          'sup_01_restorative.jpg',
          Icons.healing_rounded,
          [
            'restorative',
            'composite',
            'gic',
            'glass ionomer',
            'filling',
            'bond',
            'etch',
          ],
        ),
        SupplierProductCategory(
          'Endodontics',
          'sup_02_endodontics.jpg',
          Icons.straighten_rounded,
          ['endo', 'root canal', 'file', 'gutta', 'sealer', 'rotary'],
        ),
        SupplierProductCategory(
          'Impression materials',
          'sup_03_impression.jpg',
          Icons.layers_rounded,
          ['impression', 'alginate', 'putty', 'silicone', 'tray'],
        ),
        SupplierProductCategory(
          'Prosthodontic & cements',
          'sup_04_prosthodontic.jpg',
          Icons.science_rounded,
          ['prostho', 'cement', 'luting', 'crown', 'denture', 'acrylic'],
        ),
        SupplierProductCategory(
          'Orthodontics',
          'sup_05_orthodontics.jpg',
          Icons.grid_view_rounded,
          ['ortho', 'bracket', 'wire', 'elastic', 'ligature', 'aligner'],
        ),
        SupplierProductCategory(
          'Implants',
          'sup_06_implants.jpg',
          Icons.hardware_rounded,
          ['implant', 'abutment', 'fixture'],
        ),
        SupplierProductCategory(
          'Oral surgery & sutures',
          'sup_07_oral_surgery.jpg',
          Icons.content_cut_rounded,
          [
            'surgery',
            'surgical',
            'suture',
            'blade',
            'scalpel',
            'forcep',
            'elevator',
            'extraction',
          ],
        ),
        SupplierProductCategory(
          'Hand instruments',
          'sup_08_hand_instruments.jpg',
          Icons.edit_rounded,
          [
            'instrument',
            'mirror',
            'probe',
            'explorer',
            'tweezer',
            'plugger',
            'carver',
          ],
        ),
        SupplierProductCategory(
          'Burs & diamonds',
          'sup_09_burs.jpg',
          Icons.blur_circular_rounded,
          ['bur', 'diamond', 'polisher', 'disc'],
        ),
        SupplierProductCategory(
          'Anaesthesia & needles',
          'sup_10_anaesthesia.jpg',
          Icons.vaccines_rounded,
          [
            'anaesth',
            'anesth',
            'lignocaine',
            'lidocaine',
            'needle',
            'cartridge',
            'syringe',
          ],
        ),
        SupplierProductCategory(
          'Infection control',
          'sup_11_infection_control.jpg',
          Icons.clean_hands_rounded,
          [
            'infection',
            'glove',
            'mask',
            'disinfect',
            'steril',
            'autoclave',
            'pouch',
            'sanitiz',
          ],
        ),
        SupplierProductCategory(
          'Disposables',
          'sup_12_disposables.jpg',
          Icons.recycling_rounded,
          [
            'disposable',
            'cotton',
            'bib',
            'suction',
            'tip',
            'cup',
            'gauze',
            'consumable',
          ],
        ),
        SupplierProductCategory(
          'Preventive & whitening',
          'sup_13_preventive.jpg',
          Icons.auto_awesome_rounded,
          [
            'prevent',
            'fluoride',
            'prophy',
            'whiten',
            'bleach',
            'varnish',
            'sealant',
            'toothbrush',
            'floss',
          ],
        ),
        SupplierProductCategory(
          'Periodontics',
          'sup_14_periodontics.jpg',
          Icons.cleaning_services_rounded,
          ['perio', 'scaler', 'curette', 'ultrasonic'],
        ),
        SupplierProductCategory(
          'Paediatric',
          'sup_15_paediatric.jpg',
          Icons.child_care_rounded,
          ['paediatric', 'pediatric', 'pedo', 'child', 'kids'],
        ),
        SupplierProductCategory(
          'Radiology',
          'sup_16_radiology.jpg',
          Icons.monitor_heart_rounded,
          ['radio', 'x-ray', 'xray', 'rvg', 'sensor', 'film', 'opg', 'cbct'],
        ),
        SupplierProductCategory(
          'Equipment',
          'sup_17_equipment.jpg',
          Icons.precision_manufacturing_rounded,
          [
            'equipment',
            'machine',
            'chair',
            'light cure',
            'curing',
            'handpiece',
            'motor',
            'compressor',
            'unit',
          ],
        ),
        SupplierProductCategory(
          'Lab materials',
          'sup_18_lab_materials.jpg',
          Icons.biotech_rounded,
          ['lab material', 'plaster', 'stone', 'wax', 'investment', 'gypsum'],
        ),
        SupplierProductCategory(
          'Other',
          'sup_19_other.jpg',
          Icons.more_horiz_rounded,
          [],
        ),
      ];

  static SupplierProductCategory get other => all.last;

  /// The names, "Other" last.
  static List<String> get names => [for (final c in all) c.name];

  /// The category [category] names, or (an older free-typed category) the
  /// best match by its words and the product [title]; null when nothing fits.
  static SupplierProductCategory? find(String category, {String title = ''}) {
    final c = category.trim().toLowerCase();
    if (c.isEmpty && title.trim().isEmpty) return null;
    for (final x in all) {
      if (x.name.toLowerCase() == c) return x;
    }
    for (final hay in [c, title.trim().toLowerCase()]) {
      if (hay.isEmpty) continue;
      for (final x in all) {
        if (x.keywords.any(hay.contains)) return x;
      }
    }
    return null;
  }
}

/// A supplier category's picture, rounded, at [size]; [category] / [title]
/// are matched as [SupplierProductCategory.find] does ("Other" when nothing
/// fits).
class SupplierCategoryPicture extends StatelessWidget {
  const SupplierCategoryPicture({
    super.key,
    required this.category,
    this.title = '',
    this.size = 44,
  });

  final String category;
  final String title;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c =
        SupplierProductCategory.find(category, title: title) ??
        SupplierProductCategory.other;
    final radius = BorderRadius.circular(size * 0.24);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        color: const Color(0xFF14B8A6).withValues(alpha: 0.12),
        border: Border.all(
          color: const Color(0xFF14B8A6).withValues(alpha: 0.45),
          width: size < 28 ? 0.8 : 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          c.asset,
          package: kUiPackage,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          cacheWidth: (size * 3).round().clamp(48, 256),
          errorBuilder: (_, _, _) =>
              Icon(c.icon, size: size * 0.55, color: const Color(0xFF14B8A6)),
        ),
      ),
    );
  }
}
