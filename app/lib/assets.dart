/// Where the package's images live.
///
/// Every lookup names the package:
/// `Image.asset(UiAssets.logo, package: kUiPackage)`.
///
/// The images themselves are not part of the open-source copy; see the
/// package README.
library;

/// This package's name, for `Image.asset(..., package: kUiPackage)` and
/// `AssetImage(..., package: kUiPackage)`.
const String kUiPackage = 'identist_app';

/// Asset paths, relative to this package.
abstract final class UiAssets {
  static const String logo = 'assets/logo.png';
  static const String signInLogo = 'assets/identist_signin_logo.png';
  static const String googleLogo = 'assets/google_logo.png';

  /// Odontogram tooth images (`11.png` … `85.png`) and the facial set.
  static const String teethDir = 'assets/teeth/';

  /// Lab-work category icons and card images.
  static const String labCategoryIconsDir = 'assets/icons/lab_categories/';

  /// The supplier product categories' pictures.
  static const String supplierCategoryIconsDir =
      'assets/icons/supplier_categories/';
}

/// The lab category pictures were renamed. A lab case may have saved an old
/// picture path as its photo; it is drawn with the new picture.
String upgradeLabCategoryAsset(String path) {
  const renamed = {
    '1_zirconia_crown.png': 'lab_01_zirconia.jpg',
    '2_golden_crown.png': 'lab_02_gold.jpg',
    '3_ceramic_pfm_crown.png': 'lab_03_pfm.jpg',
    '4_metal_crown.png': 'lab_04_metal.jpg',
    '5_monolithic_crown.png': 'lab_05_monolithic.jpg',
    '6_complete_denture.png': 'lab_06_complete_denture.jpg',
    '7_removable_partial_denture.png': 'lab_07_partial_denture.jpg',
    '8_implant_supported_crown.png': 'lab_08_implant_crown.jpg',
    '9_full_arch_implant.png': 'lab_09_full_arch_implant.jpg',
    '10_clear_aligners.png': 'lab_10_aligners.jpg',
    '11_night_guards.png': 'lab_11_night_guard.jpg',
    '12_dental_veneers.png': 'lab_12_veneers.jpg',
    '13_surgical_guides.png': 'lab_13_3d_models.jpg',
    '14_temporary_provisionals.png': 'lab_14_temporary.jpg',
    '15_orthodontic_appliances.png': 'lab_15_ortho.jpg',
    '16_bleaching_trays.png': 'lab_16_trays.jpg',
  };
  if (!path.startsWith(UiAssets.labCategoryIconsDir)) return path;
  final file = path.substring(UiAssets.labCategoryIconsDir.length);
  final name =
      renamed[file] ??
      (file.endsWith('_card.png')
          ? renamed[file.replaceFirst('_card.png', '.png')]
          : null);
  return name == null ? path : '${UiAssets.labCategoryIconsDir}$name';
}
