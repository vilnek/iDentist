<div align="center">

# 🎨 identist_app

### The look of iDentist.Live, for Flutter

The same theme, glass panels, pop-ups and pickers the iDentist.Live app uses on Android, iPhone and iPad, Mac, Windows and the web.

[← Back to the main guide](../README.md)

</div>

---

## 📦 What is inside

| Folder | Files | What it gives you |
|---|---|---|
| 🎨 `theme/` | `colors.dart`, `glass_theme.dart`, `responsive.dart`, `scroll_behavior.dart` | The iDentist.Live colours, the dark and light glass look, phone / tablet / desktop sizes, and scrolling that works with mouse, touch and trackpad |
| 🪟 `panels/` | `glass_container.dart`, `popup_look.dart`, `form_dialog.dart`, `panel_dialog.dart`, `hover_card.dart` | Glass panels, themed pop-ups, a form dialog that asks before throwing away typed text, detail panels, hover cards |
| 📅 `pickers/` | `date_picker.dart`, `date_window.dart` | Date, date-range and time pickers with quick chips (Today, +1 week, Last 30 days…), full keyboard use and typed dates (dd/mm/yyyy) |
| ₹ `money/` | `money_input.dart`, `text_figures.dart` | Rupee entry fields and figures |
| 🔔 `notices/` | `top_notice.dart`, `save_failed_banner.dart` | Top notices that hide themselves or wait for an action, and a banner for a change that could not be saved |
| 🦷 `dental/` | `dental_glyphs.dart`, `product_icon.dart`, `supplier_categories.dart`, `lab_categories.dart`, `lab_category_icon.dart` | Vector glyphs for dental products, supplier product categories, and dental lab work categories (crowns, bridges, implants, aligners…) |
| ✨ `brand/` | `splash_screen.dart`, `wordmark.dart`, `brand_marks.dart`, `user_avatar.dart`, `camera_frame.dart` | Start screen, the iDentist.Live wordmark, avatars, camera frame |
| 🔤 `fonts/` | Outfit, Noto Sans, Noto Sans Gujarati | Each with its SIL Open Font License |
| 🖼️ `assets.dart` | | Names of the image paths (the images are not included) |

Everything is exported from one file: `lib/identist_app.dart`.

---

## 🚀 Use it

Add it to your `pubspec.yaml`:

```yaml
dependencies:
  identist_app:
    git:
      url: https://github.com/vilnek/iDentist.git
      path: app
```

Import it:

```dart
import 'package:identist_app/identist_app.dart';
```

For the same type, declare the fonts in your app's `pubspec.yaml`:

```yaml
flutter:
  fonts:
    - family: Outfit
      fonts:
        - asset: packages/identist_app/fonts/Outfit-Regular.ttf
        - asset: packages/identist_app/fonts/Outfit-Medium.ttf
          weight: 500
        - asset: packages/identist_app/fonts/Outfit-SemiBold.ttf
          weight: 600
        - asset: packages/identist_app/fonts/Outfit-Bold.ttf
          weight: 700
```

---

## ✅ Check it

```bash
cd app
flutter pub get
flutter analyze
flutter test
```

54 widget tests cover the dialogs, the pickers (mouse, keyboard and typed dates, small phones and big windows, every theme), the notices and the start screen.

---

## 🚫 Not included

- **Images.** The logos, tooth pictures and category pictures are not here. Category icons and brand marks fall back to a vector icon; the start screen shows an empty spot where the logo goes. Add your own images under `assets/` and list them in `pubspec.yaml` to fill them in.
- **Anything about data.** This package draws screens only. It has no network, storage, sign-in or sync code. The app's data comes from Vilnek SealedSync, explained in the [main guide](../README.md#-how-sync-works--vilnek-sealedsync).

---

<div align="center">

Code under the [MIT License](../LICENSE) · fonts under the SIL Open Font License (`lib/fonts/OFL-*.txt`)<br/>
"iDentist.Live", the iDentist tooth logo and "Vilnek" are trademarks of Vilnek Private Limited and are not covered by the code licence.

</div>
