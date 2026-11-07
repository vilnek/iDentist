import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:identist_app/panels/popup_look.dart';

/// The app's date picker: a compact card with the picked day in large type,
/// quick chips (Today, Yesterday, Tomorrow, +1 week — those inside the
/// bounds), a month grid (tap the month name for a year and month grid) and
/// a way to type the date. Keys: arrows move the day, Page Up/Down the month,
/// Enter is OK and Esc is Cancel.
///
/// Same meaning as [showDatePicker]: [initialDate] must lie between
/// [firstDate] and [lastDate]; the result is the picked day (no time) or null.
/// [currentDate] is "today" (default: now). [startWithYears] opens on the
/// year grid around [initialDate] (a date of birth: the year first).
///
/// Test keys: `ui_date_picker`, `ui_date_ok`, `ui_date_cancel`,
/// `ui_date_day_<yyyy-mm-dd>`, `ui_date_today`, `ui_date_yesterday`,
/// `ui_date_tomorrow`, `ui_date_next_week`, `ui_date_prev`, `ui_date_next`,
/// `ui_date_month_title`, `ui_date_year_<yyyy>`, `ui_date_month_<yyyy-mm>`,
/// `ui_date_header`, `ui_date_type`, `ui_date_input`.
Future<DateTime?> showUiDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? currentDate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  SelectableDayPredicate? selectableDayPredicate,
  bool useRootNavigator = true,
  bool barrierDismissible = true,
  RouteSettings? routeSettings,
  bool startWithYears = false,
}) {
  final first = _dateOnly(firstDate);
  final last = _dateOnly(lastDate);
  final initial = _dateOnly(initialDate);
  assert(
    !last.isBefore(first),
    'lastDate $last must be on or after firstDate $first.',
  );
  assert(
    !initial.isBefore(first),
    'initialDate $initial must be on or after firstDate $first.',
  );
  assert(
    !initial.isAfter(last),
    'initialDate $initial must be on or before lastDate $last.',
  );
  assert(
    selectableDayPredicate == null || selectableDayPredicate(initial),
    'initialDate $initial must satisfy selectableDayPredicate.',
  );
  return showGlassDialog<DateTime>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    routeSettings: routeSettings,
    builder: (_) => _CalendarDialog(
      range: false,
      first: first,
      last: last,
      today: _dateOnly(currentDate ?? DateTime.now()),
      initialStart: initial,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
      predicate: selectableDayPredicate,
      startWithYears: startWithYears,
    ),
  );
}

/// The app's date-range picker, in the same card as [showUiDatePicker]: tap
/// the first day, then the last (the mouse previews the span). Quick chips:
/// Last 7 days, Last 30 days, This month, Last month (those inside the
/// bounds). Keys: arrows move, Space picks the day, Enter is OK, Esc Cancel.
///
/// Same meaning as [showDateRangePicker]; the range comes back as days (no
/// time). OK with only a first day picked gives that one day.
///
/// Test keys: `ui_date_range_picker`, and the date picker's keys plus
/// `ui_range_last7`, `ui_range_last30`, `ui_range_this_month`,
/// `ui_range_last_month`, `ui_date_input_to`.
Future<DateTimeRange?> showUiDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
  DateTime? currentDate,
  String? helpText,
  String? cancelText,
  String? confirmText,
  bool useRootNavigator = true,
  bool barrierDismissible = true,
  RouteSettings? routeSettings,
}) {
  final first = _dateOnly(firstDate);
  final last = _dateOnly(lastDate);
  assert(
    !last.isBefore(first),
    'lastDate $last must be on or after firstDate $first.',
  );
  DateTime? start;
  DateTime? end;
  if (initialDateRange != null) {
    start = _dateOnly(initialDateRange.start);
    end = _dateOnly(initialDateRange.end);
    assert(
      !start.isBefore(first),
      'initialDateRange.start $start must be on or after firstDate $first.',
    );
    assert(
      !end.isAfter(last),
      'initialDateRange.end $end must be on or before lastDate $last.',
    );
  }
  return showGlassDialog<DateTimeRange>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    routeSettings: routeSettings,
    builder: (_) => _CalendarDialog(
      range: true,
      first: first,
      last: last,
      today: _dateOnly(currentDate ?? DateTime.now()),
      initialStart: start,
      initialEnd: end,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
    ),
  );
}

/// The app's time picker: the hour and minutes in large type (tap one to
/// change it, or use the small arrows), AM/PM, a grid of hours (1–12) or
/// minutes (every 5) and a "Now" chip. Keys: digits type the time, Up/Down
/// change it, Left/Right switch hour and minutes, A/P pick AM/PM, Enter is
/// OK and Esc is Cancel.
///
/// Same meaning as [showTimePicker]: the picked time or null. [currentTime]
/// is "now" for the Now chip (default: the clock).
///
/// Test keys: `ui_time_picker`, `ui_time_ok`, `ui_time_cancel`,
/// `ui_time_hour`, `ui_time_minute`, `ui_time_hour_up`, `ui_time_hour_down`,
/// `ui_time_minute_up`, `ui_time_minute_down`, `ui_time_am`, `ui_time_pm`,
/// `ui_time_h_<1-12>`, `ui_time_m_<00-55>`, `ui_time_now`.
Future<TimeOfDay?> showUiTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  DateTime? currentTime,
  String? helpText,
  String? cancelText,
  String? confirmText,
  bool useRootNavigator = true,
  bool barrierDismissible = true,
  RouteSettings? routeSettings,
}) {
  return showGlassDialog<TimeOfDay>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    routeSettings: routeSettings,
    builder: (_) => _TimeDialog(
      initial: initialTime,
      now: currentTime,
      helpText: helpText,
      cancelText: cancelText,
      confirmText: confirmText,
    ),
  );
}

const double _kWidth = 340;
const double _kTimeWidth = 320;
const double _kInset = 10;
const double _kRow = 38;
const double _kWeekRow = 24;
const double _kBody = _kWeekRow + 6 * _kRow;
const double _kYearH = 44;
const double _kYearGap = 8;
const int _kYearCols = 4;

const _weekdayShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _weekdayLetters = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
const _weekdayLong = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];
const _monthShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];
const _monthLong = [
  'January', 'February', 'March', 'April', 'May', 'June', //
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _tabular = [FontFeature.tabularFigures()];
const _red = Color(0xFFF43F5E);

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;
int _monthIndex(DateTime d) => d.year * 12 + d.month - 1;
String _two(int n) => n.toString().padLeft(2, '0');
String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';

/// Whole days from [b] to [a] (safe across clock changes).
int _dayDiff(DateTime a, DateTime b) => DateTime.utc(
  a.year,
  a.month,
  a.day,
).difference(DateTime.utc(b.year, b.month, b.day)).inDays;

/// "Fri, 9 Oct 2026".
String _dayLabel(DateTime d) =>
    '${_weekdayShort[d.weekday - 1]}, ${d.day} ${_monthShort[d.month - 1]} ${d.year}';

/// "9 Oct 2026".
String _shortDay(DateTime d) =>
    '${d.day} ${_monthShort[d.month - 1]} ${d.year}';

/// "Friday, 9 October 2026" (screen readers).
String _longDay(DateTime d) =>
    '${_weekdayLong[d.weekday - 1]}, ${d.day} ${_monthLong[d.month - 1]} ${d.year}';

/// "09/10/2026" — what the type-a-date field shows.
String _dmy(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';

/// "1 Sep – 30 Sep 2026", "28 Dec 2025 – 3 Jan 2026", or one day.
String _rangeLabel(DateTime s, DateTime e) {
  if (_sameDay(s, e)) return _shortDay(s);
  if (s.year == e.year)
    return '${s.day} ${_monthShort[s.month - 1]} – ${_shortDay(e)}';
  return '${_shortDay(s)} – ${_shortDay(e)}';
}

/// How far [d] is from [today], in plain words ("In 7 days", "41 years ago").
String _relative(DateTime d, DateTime today) {
  final n = _dayDiff(d, today);
  if (n == 0) return 'Today';
  if (n == 1) return 'Tomorrow';
  if (n == -1) return 'Yesterday';
  final a = n.abs();
  final String span;
  if (a < 14) {
    span = '$a days';
  } else if (a < 60) {
    span = '${(a / 7).round()} weeks';
  } else if (a < 730) {
    span = '${(a / 30.44).round()} months';
  } else {
    final early = n < 0 ? d : today;
    final late = n < 0 ? today : d;
    var years = late.year - early.year;
    if (late.month < early.month ||
        (late.month == early.month && late.day < early.day))
      years--;
    span = years == 1 ? '1 year' : '$years years';
  }
  return n > 0 ? 'In $span' : '$span ago';
}

/// A typed day: "9/10/2026", "09-10-26", "09.10.2026", "09102026". A two-digit
/// year is this century unless that passes [maxYear].
DateTime? _parseTyped(String text, int maxYear) {
  final t = text.trim();
  if (t.isEmpty) return null;
  final List<String> parts;
  if (RegExp(r'^\d{8}$').hasMatch(t)) {
    parts = [t.substring(0, 2), t.substring(2, 4), t.substring(4)];
  } else {
    parts = t.split(RegExp(r'[\s/.\-]+'));
  }
  if (parts.length != 3) return null;
  final d = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  var y = int.tryParse(parts[2]);
  if (d == null || m == null || y == null) return null;
  if (parts[2].length <= 2) {
    y += 2000;
    if (y > maxYear) y -= 100;
  } else if (parts[2].length != 4) {
    return null;
  }
  if (m < 1 || m > 12 || d < 1 || d > _daysInMonth(y, m)) return null;
  return DateTime(y, m, d);
}

@immutable
class _Colors {
  const _Colors({
    required this.dark,
    required this.surface,
    required this.field,
    required this.line,
    required this.accent,
    required this.accent2,
    required this.onAccent,
    required this.text,
    required this.soft,
    required this.faint,
    required this.label,
  });

  factory _Colors.of(BuildContext context) {
    final look = UiPopupScope.maybeOf(context);
    final label = Theme.of(context).textTheme.labelLarge ?? const TextStyle();
    if (look != null) {
      return _Colors(
        dark: look.dark,
        surface: look.surface,
        field: look.field,
        line: look.line,
        accent: look.accent,
        accent2: look.accent2,
        onAccent: look.onAccent,
        text: look.text,
        soft: look.soft,
        faint: look.faint,
        label: label,
      );
    }
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final accent = cs.primary;
    final hsl = HSLColor.fromColor(accent);
    final text = cs.onSurface;
    return _Colors(
      dark: dark,
      surface: Color.alphaBlend(
        accent.withValues(alpha: dark ? 0.05 : 0.02),
        cs.surface,
      ),
      field: text.withValues(alpha: dark ? 0.07 : 0.045),
      line: text.withValues(alpha: dark ? 0.12 : 0.10),
      accent: accent,
      accent2: hsl.withHue((hsl.hue + 22) % 360).toColor(),
      onAccent: (1.05 / (accent.computeLuminance() + 0.05)) >= 3
          ? Colors.white
          : const Color(0xFF0B1020),
      text: text,
      soft: text.withValues(alpha: 0.70),
      faint: text.withValues(alpha: 0.34),
      label: label,
    );
  }

  final bool dark;
  final Color surface;
  final Color field;
  final Color line;
  final Color accent;
  final Color accent2;
  final Color onAccent;
  final Color text;
  final Color soft;
  final Color faint;
  final TextStyle label;

  LinearGradient get gradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accent2],
  );
  Color get edge => accent.withValues(alpha: dark ? 0.38 : 0.30);
  Color get hover => accent.withValues(alpha: dark ? 0.18 : 0.11);
  Color get band => accent.withValues(alpha: dark ? 0.22 : 0.14);
  Color get bandSoft => accent.withValues(alpha: dark ? 0.11 : 0.07);
  Color get tint => accent.withValues(alpha: dark ? 0.20 : 0.11);
}

final WidgetStateProperty<MouseCursor> _cursor =
    WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.disabled)
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
    );

/// A button's look: [fg] words, a soft wash of [wash] (the accent) while
/// hovered or pressed, and the hand on a mouse.
ButtonStyle _buttonStyle(
  _Colors c, {
  required Color fg,
  Color? wash,
  Color? disabledFg,
  Color? fill,
  BorderSide side = BorderSide.none,
  OutlinedBorder shape = const StadiumBorder(),
  EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16),
  Size minimumSize = const Size(0, 38),
  double fontSize = 14,
}) {
  final w = wash ?? c.accent;
  return ButtonStyle(
    foregroundColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.disabled) ? (disabledFg ?? c.faint) : fg,
    ),
    iconColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.disabled) ? (disabledFg ?? c.faint) : fg,
    ),
    backgroundColor: WidgetStatePropertyAll(fill ?? Colors.transparent),
    overlayColor: WidgetStateProperty.resolveWith((s) {
      if (s.contains(WidgetState.pressed)) return w.withValues(alpha: 0.22);
      if (s.contains(WidgetState.hovered) || s.contains(WidgetState.focused))
        return w.withValues(alpha: 0.13);
      return null;
    }),
    surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    shadowColor: const WidgetStatePropertyAll(Colors.transparent),
    elevation: const WidgetStatePropertyAll(0),
    side: WidgetStatePropertyAll(side),
    mouseCursor: _cursor,
    shape: WidgetStatePropertyAll(shape),
    padding: WidgetStatePropertyAll(padding),
    minimumSize: WidgetStatePropertyAll(minimumSize),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.standard,
    textStyle: WidgetStatePropertyAll(
      c.label.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    ),
  );
}

double _pickerWidth(BuildContext context, double max) =>
    math.min(max, MediaQuery.sizeOf(context).width - 2 * _kInset);

/// The picker's window: the new design's (rounded 24, the person's colour
/// along the edge and across the top, a soft glow) in the colours above.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.pickerKey,
    required this.colors,
    required this.width,
    required this.child,
  });

  final Key pickerKey;
  final _Colors colors;
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return Dialog(
      key: pickerKey,
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 24,
      shadowColor: c.accent.withValues(alpha: c.dark ? 0.45 : 0.25),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: _kInset,
        vertical: 16,
      ),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: c.edge),
      ),
      child: SizedBox(
        width: width,
        child: Stack(
          children: [
            MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.3,
              child: SingleChildScrollView(child: child),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 3,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: c.gradient),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hover (mouse only: the hand and [builder]'s hovered look) and tap.
class _Hover extends StatefulWidget {
  const _Hover({
    super.key,
    required this.builder,
    this.onTap,
    this.onHover,
    this.semanticLabel,
    this.selected = false,
  });

  final Widget Function(bool hovered) builder;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHover;
  final String? semanticLabel;
  final bool selected;

  @override
  State<_Hover> createState() => _HoverState();
}

class _HoverState extends State<_Hover> {
  bool _hovered = false;

  void _set(bool v) {
    if (_hovered == v) return;
    setState(() => _hovered = v);
    widget.onHover?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      label: widget.semanticLabel,
      excludeSemantics: widget.semanticLabel != null,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => _set(true),
        onExit: (_) => _set(false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: widget.builder(_hovered && enabled),
        ),
      ),
    );
  }
}

/// A day, month, year, hour or minute: rounded; [selected] filled with the
/// accent gradient, [today] ringed in the accent, faded when it cannot be
/// picked; it lifts and tints under the mouse. [bandLeft]/[bandRight] draw a
/// picked range's band behind it.
class _Cell extends StatelessWidget {
  const _Cell({
    super.key,
    required this.colors,
    required this.label,
    required this.innerHeight,
    this.innerWidth,
    this.onTap,
    this.onHover,
    this.semanticLabel,
    this.selected = false,
    this.today = false,
    this.ring = false,
    this.bandLeft = false,
    this.bandRight = false,
    this.bandSoft = false,
    this.bandRoundLeft = false,
    this.bandRoundRight = false,
    this.fontSize = 14,
  });

  final _Colors colors;
  final String label;
  final double innerHeight;
  final double? innerWidth;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onHover;
  final String? semanticLabel;
  final bool selected;
  final bool today;
  final bool ring;
  final bool bandLeft;
  final bool bandRight;
  final bool bandSoft;

  /// The band ends here on the left or right (a week's edge).
  final bool bandRoundLeft;
  final bool bandRoundRight;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final enabled = onTap != null;
    return _Hover(
      onTap: onTap,
      onHover: onHover,
      selected: selected,
      semanticLabel: semanticLabel ?? label,
      builder: (hovered) {
        final fg = selected
            ? c.onAccent
            : !enabled
            ? c.faint
            : today
            ? c.accent
            : c.text;
        final Border? border = selected
            ? null
            : today
            ? Border.all(color: c.accent, width: 1.6)
            : ring
            ? Border.all(color: c.accent.withValues(alpha: 0.75), width: 1.4)
            : null;
        Widget box = AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: innerWidth,
          height: innerHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? c.gradient : null,
            color: selected
                ? null
                : (hovered ? c.hover : const Color(0x00000000)),
            borderRadius: BorderRadius.circular(12),
            border: border,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: c.accent.withValues(alpha: c.dark ? 0.45 : 0.32),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: -3,
                    ),
                  ]
                : const [],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.visible,
            softWrap: false,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: selected || today ? FontWeight.w800 : FontWeight.w600,
              color: fg,
              fontFeatures: _tabular,
            ),
          ),
        );
        box = AnimatedScale(
          scale: hovered && !selected ? 1.07 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: box,
        );
        if (!bandLeft && !bandRight) return Center(child: box);
        final band = bandSoft ? c.bandSoft : c.band;
        return Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Center(
                child: SizedBox(
                  height: innerHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: bandLeft ? band : const Color(0x00000000),
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(bandRoundLeft ? 12 : 0),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: bandRight ? band : const Color(0x00000000),
                            borderRadius: BorderRadius.horizontal(
                              right: Radius.circular(bandRoundRight ? 12 : 0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            box,
          ],
        );
      },
    );
  }
}

/// A quick pick: a small pill, tinted when it is what is picked now.
class _QuickChip extends StatelessWidget {
  const _QuickChip({
    super.key,
    required this.colors,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final _Colors colors;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return TextButton(
      onPressed: onTap,
      style: _buttonStyle(
        c,
        fg: active ? c.accent : c.text,
        fill: active ? c.tint : c.field,
        side: BorderSide(
          color: active ? c.accent.withValues(alpha: 0.75) : c.line,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        minimumSize: const Size(0, 30),
        fontSize: 12.5,
      ),
      child: Text(label),
    );
  }
}

/// A round arrow button (month, year, hour and minute steps).
Widget _roundButton(
  _Colors c, {
  required Key key,
  required IconData icon,
  required String tooltip,
  required VoidCallback? onPressed,
  double size = 36,
  double iconSize = 22,
}) {
  return IconButton(
    key: key,
    tooltip: tooltip,
    onPressed: onPressed,
    iconSize: iconSize,
    padding: EdgeInsets.zero,
    constraints: BoxConstraints.tightFor(width: size, height: size),
    style: _buttonStyle(
      c,
      fg: c.text,
      shape: const CircleBorder(),
      padding: EdgeInsets.zero,
      minimumSize: Size(size, size),
    ),
    icon: Icon(icon),
  );
}

/// Cancel and the gradient OK.
Widget _actions(
  _Colors c, {
  required String cancel,
  required String ok,
  required Key cancelKey,
  required Key okKey,
  required VoidCallback onCancel,
  required VoidCallback? onOk,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(12, 6, 14, 14),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          key: cancelKey,
          onPressed: onCancel,
          style: _buttonStyle(c, fg: c.soft, wash: c.text),
          child: Text(cancel),
        ),
        const SizedBox(width: 8),
        AnimatedOpacity(
          opacity: onOk == null ? 0.45 : 1,
          duration: const Duration(milliseconds: 160),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: c.gradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: c.accent.withValues(alpha: c.dark ? 0.42 : 0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: TextButton(
              key: okKey,
              onPressed: onOk,
              style: _buttonStyle(
                c,
                fg: c.onAccent,
                wash: c.onAccent,
                disabledFg: c.onAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(ok),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Opens with the picked year in the middle of the year grid.
class _YearsController extends ScrollController {
  _YearsController() : super(keepScrollOffset: false);

  double startOffset = 0;

  @override
  double get initialScrollOffset => startOffset;
}

enum _View { days, years, months }

class _CalendarDialog extends StatefulWidget {
  const _CalendarDialog({
    required this.range,
    required this.first,
    required this.last,
    required this.today,
    this.initialStart,
    this.initialEnd,
    this.helpText,
    this.cancelText,
    this.confirmText,
    this.predicate,
    this.startWithYears = false,
  });

  final bool range;
  final bool startWithYears;
  final DateTime first;
  final DateTime last;
  final DateTime today;
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final String? helpText;
  final String? cancelText;
  final String? confirmText;
  final SelectableDayPredicate? predicate;

  @override
  State<_CalendarDialog> createState() => _CalendarDialogState();
}

class _CalendarDialogState extends State<_CalendarDialog> {
  /// The picked day (a range's first day).
  DateTime? _start;

  /// A range's last day (null while it is being picked).
  DateTime? _end;

  /// A range: the day under the mouse while the last day is being picked.
  DateTime? _hover;

  /// The day the arrow keys are on.
  late DateTime _cursor;

  /// A range: ring the keys' day once the keys are used.
  bool _keyboard = false;

  /// The first day of the month on show.
  late DateTime _shown;

  /// The year on show in the month grid.
  late int _year;

  /// 1 when the last month change went forward, -1 back.
  int _slide = 1;
  _View _view = _View.days;

  bool _typing = false;
  bool _typedOk = true;
  String? _typeError;
  bool _closed = false;

  final _keys = FocusNode(debugLabel: 'ui_date_picker');
  final _typeFrom = TextEditingController();
  final _typeTo = TextEditingController();
  final _typeFromFocus = FocusNode(debugLabel: 'ui_date_input');
  final _typeToFocus = FocusNode(debugLabel: 'ui_date_input_to');
  final _years = _YearsController();

  bool get _range => widget.range;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = _range ? widget.initialEnd : null;
    final anchor = (_range ? (_end ?? _start) : _start) ?? _clamp(widget.today);
    _cursor = anchor;
    _shown = DateTime(anchor.year, anchor.month);
    _year = anchor.year;
    if (widget.startWithYears) {
      _placeYears();
      _view = _View.years;
    }
  }

  @override
  void dispose() {
    _keys.dispose();
    _typeFrom.dispose();
    _typeTo.dispose();
    _typeFromFocus.dispose();
    _typeToFocus.dispose();
    _years.dispose();
    super.dispose();
  }

  DateTime _clamp(DateTime d) {
    if (d.isBefore(widget.first)) return widget.first;
    if (d.isAfter(widget.last)) return widget.last;
    return d;
  }

  bool _inBounds(DateTime d) =>
      !d.isBefore(widget.first) && !d.isAfter(widget.last);
  bool _selectable(DateTime d) =>
      _inBounds(d) && (widget.predicate?.call(d) ?? true);

  /// Shows [d]'s month, sliding the right way. Call inside setState.
  void _showMonth(DateTime d) {
    final to = _monthIndex(d);
    final from = _monthIndex(_shown);
    if (to == from) return;
    _slide = to > from ? 1 : -1;
    _shown = DateTime(d.year, d.month);
  }

  bool get _canPrevMonth => _monthIndex(_shown) > _monthIndex(widget.first);
  bool get _canNextMonth => _monthIndex(_shown) < _monthIndex(widget.last);

  void _stepMonth(int n) {
    final to = DateTime(_shown.year, _shown.month + n);
    if (_monthIndex(to) < _monthIndex(widget.first) ||
        _monthIndex(to) > _monthIndex(widget.last))
      return;
    setState(() => _showMonth(to));
  }

  void _tapDay(DateTime d) {
    if (!_selectable(d)) return;
    setState(() {
      _cursor = d;
      if (!_range) {
        _start = d;
      } else if (_start != null && _end == null && !d.isBefore(_start!)) {
        _end = d;
        _hover = null;
      } else {
        _start = d;
        _end = null;
      }
      _showMonth(d);
      _syncTyped();
    });
  }

  void _hoverDay(DateTime d, bool on) {
    if (_start == null || _end != null) {
      if (_hover != null) setState(() => _hover = null);
      return;
    }
    if (on) {
      if (_hover == null || !_sameDay(_hover!, d)) setState(() => _hover = d);
    } else if (_hover != null && _sameDay(_hover!, d)) {
      setState(() => _hover = null);
    }
  }

  /// The arrow keys: [days] on from the keys' day, skipping days that cannot
  /// be picked; nothing past the bounds.
  void _moveBy(int days) {
    final from = _range ? _cursor : (_start ?? _cursor);
    var d = _addDays(from, days);
    var guard = 0;
    while (_inBounds(d) && !_selectable(d) && guard++ < 400) {
      d = _addDays(d, days.sign);
    }
    if (!_selectable(d)) return;
    _keyTo(d);
  }

  /// Page Up/Down: the same day a month (Shift: a year) away.
  void _moveMonths(int n) {
    final from = _range ? _cursor : (_start ?? _cursor);
    final firstOf = DateTime(from.year, from.month + n);
    final d = _clamp(
      DateTime(
        firstOf.year,
        firstOf.month,
        math.min(from.day, _daysInMonth(firstOf.year, firstOf.month)),
      ),
    );
    if (!_selectable(d)) return;
    _keyTo(d);
  }

  void _keyTo(DateTime d) {
    setState(() {
      _keyboard = true;
      _cursor = d;
      if (!_range) _start = d;
      _showMonth(d);
      _syncTyped();
    });
  }

  void _openYears() {
    _placeYears();
    setState(() => _view = _View.years);
  }

  /// Puts the shown year in the middle of the year grid.
  void _placeYears() {
    final count = widget.last.year - widget.first.year + 1;
    final rows = (count + _kYearCols - 1) ~/ _kYearCols;
    final row =
        (_shown.year - widget.first.year).clamp(0, count - 1) ~/ _kYearCols;
    final max = math.max(
      0.0,
      rows * (_kYearH + _kYearGap) - _kYearGap - _kBody,
    );
    _years.startOffset = (row * (_kYearH + _kYearGap) - (_kBody - _kYearH) / 2)
        .clamp(0.0, max);
  }

  void _pickYear(int y) => setState(() {
    _year = y;
    _view = _View.months;
  });

  void _stepYear(int n) {
    final y = _year + n;
    if (y < widget.first.year || y > widget.last.year) return;
    setState(() => _year = y);
  }

  void _pickMonth(int m) {
    setState(() {
      if (!_range && _start != null) {
        final d = _clamp(
          DateTime(_year, m, math.min(_start!.day, _daysInMonth(_year, m))),
        );
        if (d.year == _year && d.month == m && _selectable(d)) {
          _start = d;
          _cursor = d;
          _syncTyped();
        }
      }
      _showMonth(DateTime(_year, m));
      _view = _View.days;
    });
  }

  List<(String, String, DateTime)> get _dayChips {
    final t = widget.today;
    return [
      for (final chip in [
        ('ui_date_today', 'Today', t),
        ('ui_date_yesterday', 'Yesterday', _addDays(t, -1)),
        ('ui_date_tomorrow', 'Tomorrow', _addDays(t, 1)),
        ('ui_date_next_week', '+1 week', _addDays(t, 7)),
      ])
        if (_selectable(chip.$3)) chip,
    ];
  }

  List<(String, String, DateTime, DateTime)> get _rangeChips {
    final t = widget.today;
    return [
      for (final chip in [
        ('ui_range_last7', 'Last 7 days', _addDays(t, -6), t),
        ('ui_range_last30', 'Last 30 days', _addDays(t, -29), t),
        ('ui_range_this_month', 'This month', DateTime(t.year, t.month), t),
        (
          'ui_range_last_month',
          'Last month',
          DateTime(t.year, t.month - 1),
          DateTime(t.year, t.month, 0),
        ),
      ])
        if (_inBounds(chip.$3) && _inBounds(chip.$4)) chip,
    ];
  }

  void _pickChipDay(DateTime d) => setState(() {
    _start = d;
    _cursor = d;
    _view = _View.days;
    _showMonth(d);
    _syncTyped();
  });

  void _pickChipRange(DateTime s, DateTime e) => setState(() {
    _start = s;
    _end = e;
    _hover = null;
    _cursor = e;
    _view = _View.days;
    _showMonth(e);
    _syncTyped();
  });

  void _toggleTyping() {
    setState(() {
      _typing = !_typing;
      _typeError = null;
      if (_typing) {
        _typeFrom.text = _start == null ? '' : _dmy(_start!);
        _typeFrom.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _typeFrom.text.length,
        );
        _typeTo.text = _end == null ? '' : _dmy(_end!);
        _typedOk = _range ? (_start != null && _end != null) : _start != null;
      } else {
        _typedOk = true;
      }
    });
    if (!_typing) _keys.requestFocus();
  }

  /// The fields follow what is picked on the calendar. Call inside setState.
  void _syncTyped() {
    if (!_typing) return;
    void put(TextEditingController ctrl, DateTime? d) {
      final t = d == null ? '' : _dmy(d);
      if (ctrl.text != t) {
        ctrl.value = TextEditingValue(
          text: t,
          selection: TextSelection.collapsed(offset: t.length),
        );
      }
    }

    put(_typeFrom, _start);
    if (_range) put(_typeTo, _end);
    _typeError = null;
    _typedOk = _range ? (_start != null && _end != null) : _start != null;
  }

  String? _typedProblem(String text, DateTime? d) {
    if (d == null)
      return text.trim().length >= 8 ? 'Type the date as dd/mm/yyyy' : null;
    if (!_inBounds(d))
      return 'Pick a day from ${_shortDay(widget.first)} to ${_shortDay(widget.last)}';
    if (!(widget.predicate?.call(d) ?? true))
      return 'This day cannot be picked';
    return null;
  }

  void _onTyped() {
    final maxYear = widget.last.year;
    final a = _parseTyped(_typeFrom.text, maxYear);
    if (!_range) {
      final err = _typedProblem(_typeFrom.text, a);
      setState(() {
        _typeError = err;
        _typedOk = a != null && err == null;
        if (_typedOk) {
          _start = a;
          _cursor = a!;
          _showMonth(a);
        }
      });
      return;
    }
    final b = _parseTyped(_typeTo.text, maxYear);
    var err =
        _typedProblem(_typeFrom.text, a) ?? _typedProblem(_typeTo.text, b);
    if (err == null && a != null && b != null && b.isBefore(a))
      err = 'The last day is before the first day';
    setState(() {
      _typeError = err;
      _typedOk = a != null && b != null && err == null;
      if (_typedOk) {
        _start = a;
        _end = b;
        _hover = null;
        _cursor = b!;
        _showMonth(b);
      }
    });
  }

  bool get _canOk => _start != null && (!_typing || _typedOk);

  void _ok() {
    if (_closed || !_canOk) return;
    _closed = true;
    Navigator.of(context).pop(
      _range ? DateTimeRange(start: _start!, end: _end ?? _start!) : _start,
    );
  }

  void _cancel() {
    if (_closed) return;
    _closed = true;
    Navigator.of(context).pop();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _cancel();
      return KeyEventResult.handled;
    }
    final primary = FocusManager.instance.primaryFocus;
    final onMe = primary == _keys;
    final inField = primary == _typeFromFocus || primary == _typeToFocus;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (!onMe && !inField) return KeyEventResult.ignored;
      _ok();
      return KeyEventResult.handled;
    }
    if (!onMe || _view != _View.days) return KeyEventResult.ignored;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final days = switch (key) {
      LogicalKeyboardKey.arrowLeft => -1,
      LogicalKeyboardKey.arrowRight => 1,
      LogicalKeyboardKey.arrowUp => -7,
      LogicalKeyboardKey.arrowDown => 7,
      _ => 0,
    };
    if (days != 0) {
      _moveBy(days);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.pageUp ||
        key == LogicalKeyboardKey.pageDown) {
      _moveMonths(
        (key == LogicalKeyboardKey.pageDown ? 1 : -1) * (shift ? 12 : 1),
      );
      return KeyEventResult.handled;
    }
    if (_range && key == LogicalKeyboardKey.space) {
      _tapDay(_cursor);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final c = _Colors.of(context);
    final width = _pickerWidth(context, _kWidth);
    final inner = width - 24;
    final hasChips = _range ? _rangeChips.isNotEmpty : _dayChips.isNotEmpty;
    return _Frame(
      pickerKey: Key(_range ? 'ui_date_range_picker' : 'ui_date_picker'),
      colors: c,
      width: width,
      child: Focus(
        focusNode: _keys,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(c),
            if (hasChips) _chips(c),
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: c.line,
            ),
            _titleRow(c),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _body(c, inner),
              ),
            ),
            _actions(
              c,
              cancel: widget.cancelText ?? 'Cancel',
              ok: widget.confirmText ?? 'OK',
              cancelKey: const Key('ui_date_cancel'),
              okKey: const Key('ui_date_ok'),
              onCancel: _cancel,
              onOk: _canOk ? _ok : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(_Colors c) {
    final help = widget.helpText ?? (_range ? 'Select range' : 'Select date');
    final String big;
    final String caption;
    if (!_range) {
      big = _start == null ? 'Pick a day' : _dayLabel(_start!);
      caption = _start == null ? '' : _relative(_start!, widget.today);
    } else if (_start == null) {
      big = 'Pick the first day';
      caption = '';
    } else if (_end == null) {
      big = '${_shortDay(_start!)} – …';
      caption = 'Now pick the last day';
    } else {
      big = _rangeLabel(_start!, _end!);
      final n = _dayDiff(_end!, _start!) + 1;
      caption = n == 1 ? '1 day' : '$n days';
    }
    Widget fadeSlide(Widget child, Animation<double> a) => FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.25),
          end: Offset.zero,
        ).animate(a),
        child: child,
      ),
    );
    Widget leftStack(Widget? current, List<Widget> previous) => Stack(
      alignment: Alignment.centerLeft,
      children: [...previous, ?current],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 10, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  help,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.soft,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topLeft,
                  child: _typing
                      ? _typedFields(c)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: fadeSlide,
                              layoutBuilder: leftStack,
                              child: FittedBox(
                                key: ValueKey(big),
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  big,
                                  key: const Key('ui_date_header'),
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w900,
                                    color: c.text,
                                    letterSpacing: -0.4,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                            if (caption.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  layoutBuilder: leftStack,
                                  child: Text(
                                    caption,
                                    key: ValueKey(caption),
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: c.accent,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          _roundButton(
            c,
            key: const Key('ui_date_type'),
            icon: _typing
                ? Icons.calendar_month_rounded
                : Icons.keyboard_rounded,
            tooltip: _typing ? 'Pick on the calendar' : 'Type a date',
            onPressed: _toggleTyping,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _typedFields(_Colors c) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
    Widget field(
      Key key,
      TextEditingController ctrl,
      FocusNode focus, {
      required bool autofocus,
      required bool last,
    }) {
      return TextField(
        key: key,
        controller: ctrl,
        focusNode: focus,
        autofocus: autofocus,
        keyboardType: TextInputType.datetime,
        textInputAction: last ? TextInputAction.done : TextInputAction.next,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9/.\- ]')),
          LengthLimitingTextInputFormatter(10),
        ],
        cursorColor: c.accent,
        style: TextStyle(
          fontSize: _range ? 15 : 19,
          fontWeight: FontWeight.w800,
          color: c.text,
          fontFeatures: _tabular,
        ),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'dd/mm/yyyy',
          hintStyle: TextStyle(color: c.faint, fontWeight: FontWeight.w600),
          filled: true,
          fillColor: c.field,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          enabledBorder: border(_typeError != null ? _red : c.line),
          focusedBorder: border(_typeError != null ? _red : c.accent, 1.6),
          border: border(c.line),
        ),
        onChanged: (_) => _onTyped(),
        onSubmitted: (_) {
          if (!last) {
            _typeToFocus.requestFocus();
          } else {
            _ok();
          }
        },
      );
    }

    final from = field(
      const Key('ui_date_input'),
      _typeFrom,
      _typeFromFocus,
      autofocus: true,
      last: !_range,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_range)
            from
          else
            Row(
              children: [
                Expanded(child: from),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    '–',
                    style: TextStyle(
                      color: c.soft,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: field(
                    const Key('ui_date_input_to'),
                    _typeTo,
                    _typeToFocus,
                    autofocus: false,
                    last: true,
                  ),
                ),
              ],
            ),
          if (_typeError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _typeError!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chips(_Colors c) {
    final chips = <Widget>[
      if (!_range)
        for (final (key, label, day) in _dayChips)
          _QuickChip(
            key: Key(key),
            colors: c,
            label: label,
            active: _start != null && _sameDay(_start!, day),
            onTap: () => _pickChipDay(day),
          )
      else
        for (final (key, label, s, e) in _rangeChips)
          _QuickChip(
            key: Key(key),
            colors: c,
            label: label,
            active:
                _start != null &&
                _end != null &&
                _sameDay(_start!, s) &&
                _sameDay(_end!, e),
            onTap: () => _pickChipRange(s, e),
          ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Wrap(spacing: 6, runSpacing: 6, children: chips),
    );
  }

  Widget _titleRow(_Colors c) {
    final String title;
    final VoidCallback onTitle;
    final bool up;
    var arrows = true;
    var prevTip = 'Previous month';
    var nextTip = 'Next month';
    VoidCallback? onPrev;
    VoidCallback? onNext;
    switch (_view) {
      case _View.days:
        title = '${_monthLong[_shown.month - 1]} ${_shown.year}';
        onTitle = _openYears;
        up = false;
        onPrev = _canPrevMonth ? () => _stepMonth(-1) : null;
        onNext = _canNextMonth ? () => _stepMonth(1) : null;
      case _View.years:
        title = 'Pick a year';
        onTitle = () => setState(() => _view = _View.days);
        up = true;
        arrows = false;
      case _View.months:
        title = '$_year';
        onTitle = _openYears;
        up = false;
        prevTip = 'Previous year';
        nextTip = 'Next year';
        onPrev = _year > widget.first.year ? () => _stepYear(-1) : null;
        onNext = _year < widget.last.year ? () => _stepYear(1) : null;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: const Key('ui_date_month_title'),
                onPressed: onTitle,
                style: _buttonStyle(
                  c,
                  fg: c.text,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 36),
                  fontSize: 15.5,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 2),
                    AnimatedRotation(
                      turns: up ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: c.soft,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (arrows) ...[
            _roundButton(
              c,
              key: const Key('ui_date_prev'),
              icon: Icons.chevron_left_rounded,
              tooltip: prevTip,
              onPressed: onPrev,
            ),
            const SizedBox(width: 4),
            _roundButton(
              c,
              key: const Key('ui_date_next'),
              icon: Icons.chevron_right_rounded,
              tooltip: nextTip,
              onPressed: onNext,
            ),
          ],
        ],
      ),
    );
  }

  Widget _body(_Colors c, double inner) {
    final child = switch (_view) {
      _View.days => Column(
        key: const ValueKey('days'),
        mainAxisSize: MainAxisSize.min,
        children: [_weekdayRow(c, inner), _monthSwitcher(c, inner)],
      ),
      _View.years => KeyedSubtree(
        key: const ValueKey('years'),
        child: _yearsGrid(c),
      ),
      _View.months => KeyedSubtree(
        key: const ValueKey('months'),
        child: _monthsGrid(c),
      ),
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(a),
          child: child,
        ),
      ),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      child: child,
    );
  }

  Widget _weekdayRow(_Colors c, double inner) {
    return SizedBox(
      height: _kWeekRow,
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            SizedBox(
              width: inner / 7,
              child: Center(
                child: Text(
                  _weekdayLetters[i],
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: c.soft,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// The month grid, sliding left or right as the month changes (as many
  /// rows as the month needs).
  Widget _monthSwitcher(_Colors c, double inner) {
    final shownKey = ValueKey<int>(_monthIndex(_shown));
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, ?current],
        ),
        transitionBuilder: (child, a) {
          final incoming = child.key == shownKey;
          final dx = 0.14 * _slide * (incoming ? 1 : -1);
          return FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween(
                begin: Offset(dx, 0),
                end: Offset.zero,
              ).animate(a),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(key: shownKey, child: _daysGrid(c, _shown, inner)),
      ),
    );
  }

  Widget _daysGrid(_Colors c, DateTime month, double inner) {
    final w = inner / 7;
    final lead = DateTime(month.year, month.month).weekday - 1;
    final count = _daysInMonth(month.year, month.month);
    final rows = (lead + count + 6) ~/ 7;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                SizedBox(
                  width: w,
                  height: _kRow,
                  child: () {
                    final n = r * 7 + col - lead + 1;
                    if (n < 1 || n > count) return const SizedBox.shrink();
                    return _dayCell(c, DateTime(month.year, month.month, n), w);
                  }(),
                ),
            ],
          ),
      ],
    );
  }

  Widget _dayCell(_Colors c, DateTime d, double w) {
    final enabled = _selectable(d);
    var selected = false;
    var bandLeft = false;
    var bandRight = false;
    var preview = false;
    var previewEnd = false;
    if (!_range) {
      selected = _start != null && _sameDay(d, _start!);
    } else if (_start != null) {
      final s = _start!;
      var e = _end;
      if (e == null && _hover != null && _hover!.isAfter(s)) {
        e = _hover;
        preview = true;
      }
      final isStart = _sameDay(d, s);
      final isEnd = e != null && _sameDay(d, e);
      selected = isStart || (isEnd && !preview);
      previewEnd = isEnd && preview;
      if (e != null && e.isAfter(s)) {
        final inside = d.isAfter(s) && d.isBefore(e);
        bandLeft = inside || isEnd;
        bandRight = inside || isStart;
      }
    }
    return _Cell(
      key: Key('ui_date_day_${_iso(d)}'),
      colors: c,
      label: '${d.day}',
      semanticLabel: _longDay(d),
      selected: selected,
      today: _sameDay(d, widget.today),
      ring: previewEnd || (_keyboard && _range && _sameDay(d, _cursor)),
      bandLeft: bandLeft,
      bandRight: bandRight,
      bandSoft: preview,
      bandRoundLeft: d.weekday == DateTime.monday || d.day == 1,
      bandRoundRight:
          d.weekday == DateTime.sunday ||
          d.day == _daysInMonth(d.year, d.month),
      innerWidth: math.min(w - 4, 40),
      innerHeight: _kRow - 4,
      onTap: enabled ? () => _tapDay(d) : null,
      onHover: _range && enabled ? (on) => _hoverDay(d, on) : null,
    );
  }

  Widget _yearsGrid(_Colors c) {
    final from = widget.first.year;
    final count = widget.last.year - from + 1;
    final picked = _start?.year;
    final rows = (count + _kYearCols - 1) ~/ _kYearCols;
    return SizedBox(
      key: const Key('ui_date_years'),
      height: math.min(_kBody, rows * (_kYearH + _kYearGap) - _kYearGap + 4),
      child: GridView.builder(
        controller: _years,
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _kYearCols,
          mainAxisExtent: _kYearH,
          mainAxisSpacing: _kYearGap,
          crossAxisSpacing: _kYearGap,
        ),
        itemCount: count,
        itemBuilder: (_, i) {
          final y = from + i;
          return _Cell(
            key: Key('ui_date_year_$y'),
            colors: c,
            label: '$y',
            selected: y == picked,
            today: y == widget.today.year,
            ring: picked == null && y == _shown.year,
            innerHeight: _kYearH,
            fontSize: 14.5,
            onTap: () => _pickYear(y),
          );
        },
      ),
    );
  }

  Widget _monthsGrid(_Colors c) {
    const gap = 8.0;
    const rows = 4;
    const cols = 3;
    const h = (_kBody - 6 - gap * (rows - 1)) / rows;
    final from = _monthIndex(widget.first);
    final to = _monthIndex(widget.last);
    final picked = _start;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Padding(
        key: ValueKey<int>(_year),
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          children: [
            for (var r = 0; r < rows; r++) ...[
              if (r > 0) const SizedBox(height: gap),
              Row(
                children: [
                  for (var col = 0; col < cols; col++) ...[
                    if (col > 0) const SizedBox(width: gap),
                    Expanded(
                      child: () {
                        final m = r * cols + col + 1;
                        final index = _year * 12 + m - 1;
                        return _Cell(
                          key: Key('ui_date_month_$_year-${_two(m)}'),
                          colors: c,
                          label: _monthShort[m - 1],
                          semanticLabel: '${_monthLong[m - 1]} $_year',
                          selected:
                              picked != null &&
                              picked.year == _year &&
                              picked.month == m,
                          today:
                              widget.today.year == _year &&
                              widget.today.month == m,
                          innerHeight: h,
                          fontSize: 14.5,
                          onTap: index >= from && index <= to
                              ? () => _pickMonth(m)
                              : null,
                        );
                      }(),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _Part { hour, minute }

const _digitKeys = [
  LogicalKeyboardKey.digit0,
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2, //
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
];
const _numpadKeys = [
  LogicalKeyboardKey.numpad0,
  LogicalKeyboardKey.numpad1,
  LogicalKeyboardKey.numpad2, //
  LogicalKeyboardKey.numpad3,
  LogicalKeyboardKey.numpad4,
  LogicalKeyboardKey.numpad5,
  LogicalKeyboardKey.numpad6,
  LogicalKeyboardKey.numpad7,
  LogicalKeyboardKey.numpad8,
  LogicalKeyboardKey.numpad9,
];

class _TimeDialog extends StatefulWidget {
  const _TimeDialog({
    required this.initial,
    this.now,
    this.helpText,
    this.cancelText,
    this.confirmText,
  });

  final TimeOfDay initial;
  final DateTime? now;
  final String? helpText;
  final String? cancelText;
  final String? confirmText;

  @override
  State<_TimeDialog> createState() => _TimeDialogState();
}

class _TimeDialogState extends State<_TimeDialog> {
  late int _h12;
  late int _minute;
  late bool _pm;
  _Part _part = _Part.hour;

  /// The first digit typed for the part, waiting for a second.
  String _typed = '';
  bool _closed = false;
  final _keys = FocusNode(debugLabel: 'ui_time_picker');

  @override
  void initState() {
    super.initState();
    _setTime(widget.initial);
  }

  @override
  void dispose() {
    _keys.dispose();
    super.dispose();
  }

  void _setTime(TimeOfDay t) {
    _pm = t.hour >= 12;
    _h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
    _minute = t.minute;
  }

  TimeOfDay get _time =>
      TimeOfDay(hour: (_h12 % 12) + (_pm ? 12 : 0), minute: _minute);

  /// Up/down: an hour or a minute on, across noon and midnight.
  void _step(_Part part, int n) {
    final t = _time;
    final total = t.hour * 60 + t.minute + n * (part == _Part.hour ? 60 : 1);
    final wrapped = ((total % 1440) + 1440) % 1440;
    setState(() {
      _setTime(TimeOfDay(hour: wrapped ~/ 60, minute: wrapped % 60));
      _part = part;
      _typed = '';
    });
  }

  void _digit(int d) {
    setState(() {
      if (_part == _Part.hour) {
        if (_typed.isEmpty) {
          if (d <= 1) {
            _typed = '$d';
            if (d == 1) _h12 = 1;
          } else {
            _h12 = d;
            _part = _Part.minute;
          }
        } else {
          final v = int.parse(_typed) * 10 + d;
          _typed = '';
          if (v >= 1 && v <= 12) {
            _h12 = v;
            _part = _Part.minute;
          }
        }
      } else {
        if (_typed.isEmpty) {
          _minute = d;
          if (d <= 5) _typed = '$d';
        } else {
          _minute = int.parse(_typed) * 10 + d;
          _typed = '';
        }
      }
    });
  }

  void _ok() {
    if (_closed) return;
    _closed = true;
    Navigator.of(context).pop(_time);
  }

  void _cancel() {
    if (_closed) return;
    _closed = true;
    Navigator.of(context).pop();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      _cancel();
      return KeyEventResult.handled;
    }
    if (FocusManager.instance.primaryFocus != _keys)
      return KeyEventResult.ignored;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _ok();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown) {
      _step(_part, key == LogicalKeyboardKey.arrowUp ? 1 : -1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight) {
      setState(() {
        _part = _part == _Part.hour ? _Part.minute : _Part.hour;
        _typed = '';
      });
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.keyA || key == LogicalKeyboardKey.keyP) {
      setState(() => _pm = key == LogicalKeyboardKey.keyP);
      return KeyEventResult.handled;
    }
    var digit = _digitKeys.indexOf(key);
    if (digit < 0) digit = _numpadKeys.indexOf(key);
    if (digit >= 0) {
      _digit(digit);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final c = _Colors.of(context);
    final width = _pickerWidth(context, _kTimeWidth);
    final inner = width - 24;
    final now = widget.now ?? DateTime.now();
    final nowTime = TimeOfDay(hour: now.hour, minute: now.minute);
    return _Frame(
      pickerKey: const Key('ui_time_picker'),
      colors: c,
      width: width,
      child: Focus(
        focusNode: _keys,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 14, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.helpText ?? 'Select time',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: c.soft,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  _QuickChip(
                    key: const Key('ui_time_now'),
                    colors: c,
                    label: 'Now',
                    active: _time == nowTime,
                    onTap: () => setState(() {
                      _setTime(nowTime);
                      _typed = '';
                    }),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _segment(c, _Part.hour, '$_h12'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        ':',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: c.soft,
                        ),
                      ),
                    ),
                    _segment(c, _Part.minute, _two(_minute)),
                    const SizedBox(width: 14),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _period(
                          c,
                          'AM',
                          !_pm,
                          const Key('ui_time_am'),
                          () => setState(() => _pm = false),
                        ),
                        const SizedBox(height: 6),
                        _period(
                          c,
                          'PM',
                          _pm,
                          const Key('ui_time_pm'),
                          () => setState(() => _pm = true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                _part == _Part.hour ? 'Hour' : 'Minutes',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: c.soft,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                height: 2 * 40,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, a) => FadeTransition(
                    opacity: a,
                    child: ScaleTransition(
                      scale: Tween(begin: 0.96, end: 1.0).animate(a),
                      child: child,
                    ),
                  ),
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...previous, ?current],
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_part),
                    child: _grid(c, inner),
                  ),
                ),
              ),
            ),
            _actions(
              c,
              cancel: widget.cancelText ?? 'Cancel',
              ok: widget.confirmText ?? 'OK',
              cancelKey: const Key('ui_time_cancel'),
              okKey: const Key('ui_time_ok'),
              onCancel: _cancel,
              onOk: _ok,
            ),
          ],
        ),
      ),
    );
  }

  /// The hour or the minutes in large type, with small up and down arrows.
  Widget _segment(_Colors c, _Part part, String value) {
    final active = _part == part;
    final name = part == _Part.hour ? 'hour' : 'minute';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _roundButton(
          c,
          key: Key('ui_time_${name}_up'),
          icon: Icons.keyboard_arrow_up_rounded,
          tooltip: part == _Part.hour ? 'Next hour' : 'Next minute',
          onPressed: () => _step(part, 1),
          size: 30,
          iconSize: 22,
        ),
        _Hover(
          key: Key('ui_time_$name'),
          selected: active,
          semanticLabel: part == _Part.hour ? 'Hour $value' : 'Minutes $value',
          onTap: () => setState(() {
            _part = part;
            _typed = '';
          }),
          builder: (hovered) => AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            width: 80,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? c.tint : (hovered ? c.hover : c.field),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? c.accent : c.line,
                width: active ? 1.8 : 1,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: c.accent.withValues(alpha: c.dark ? 0.35 : 0.22),
                        blurRadius: 14,
                        spreadRadius: -4,
                      ),
                    ]
                  : const [],
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: active ? c.accent : c.text,
                fontFeatures: _tabular,
                height: 1.1,
              ),
            ),
          ),
        ),
        _roundButton(
          c,
          key: Key('ui_time_${name}_down'),
          icon: Icons.keyboard_arrow_down_rounded,
          tooltip: part == _Part.hour ? 'Previous hour' : 'Previous minute',
          onPressed: () => _step(part, -1),
          size: 30,
          iconSize: 22,
        ),
      ],
    );
  }

  Widget _period(
    _Colors c,
    String label,
    bool on,
    Key key,
    VoidCallback onTap,
  ) {
    return _Hover(
      key: key,
      selected: on,
      semanticLabel: label,
      onTap: onTap,
      builder: (hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 54,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: on ? c.gradient : null,
          color: on ? null : (hovered ? c.hover : c.field),
          borderRadius: BorderRadius.circular(10),
          border: on ? null : Border.all(color: c.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: on ? c.onAccent : c.soft,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  /// Hours 1–12 or minutes in fives, six to a row.
  Widget _grid(_Colors c, double inner) {
    final w = inner / 6;
    final hours = _part == _Part.hour;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < 2; r++)
          Row(
            children: [
              for (var col = 0; col < 6; col++)
                SizedBox(
                  width: w,
                  height: 40,
                  child: () {
                    final i = r * 6 + col;
                    if (hours) {
                      final h = i + 1;
                      return _Cell(
                        key: Key('ui_time_h_$h'),
                        colors: c,
                        label: '$h',
                        semanticLabel: '$h ${_pm ? 'PM' : 'AM'}',
                        selected: _h12 == h,
                        innerWidth: math.min(w - 4, 44),
                        innerHeight: 36,
                        onTap: () => setState(() {
                          _h12 = h;
                          _part = _Part.minute;
                          _typed = '';
                        }),
                      );
                    }
                    final m = i * 5;
                    return _Cell(
                      key: Key('ui_time_m_${_two(m)}'),
                      colors: c,
                      label: _two(m),
                      semanticLabel: '${_two(m)} minutes',
                      selected: _minute == m,
                      innerWidth: math.min(w - 4, 44),
                      innerHeight: 36,
                      onTap: () => setState(() {
                        _minute = m;
                        _typed = '';
                      }),
                    );
                  }(),
                ),
            ],
          ),
      ],
    );
  }
}
