import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identist_app/identist_app.dart';

const _darkLook = UiPopupLook(
  dark: true,
  surface: Color(0xFF111827),
  card: Color(0xFF1F2937),
  field: Color(0x0FFFFFFF),
  line: Color(0x1FFFFFFF),
  accent: Color(0xFF22D3EE),
  accent2: Color(0xFF818CF8),
  onAccent: Color(0xFF0B1020),
  text: Colors.white,
  soft: Color(0xB3FFFFFF),
  faint: Color(0x59FFFFFF),
);
const _lightLook = UiPopupLook(
  dark: false,
  surface: Color(0xFFF8FAFC),
  card: Colors.white,
  field: Color(0x0A000000),
  line: Color(0x17000000),
  accent: Color(0xFF4F46E5),
  accent2: Color(0xFF7C3AED),
  onAccent: Colors.white,
  text: Color(0xFF0B0B0F),
  soft: Color(0xA60B0B0F),
  faint: Color(0x590B0B0F),
);
const _blackLook = UiPopupLook(
  dark: true,
  surface: Colors.black,
  card: Color(0xFF0A0A0A),
  field: Color(0x0FFFFFFF),
  line: Color(0x24FFFFFF),
  accent: Color(0xFF22D3EE),
  accent2: Color(0xFF06B6D4),
  onAccent: Color(0xFF0B1020),
  text: Colors.white,
  soft: Color(0xB3FFFFFF),
  faint: Color(0x59FFFFFF),
);
const _whiteLook = UiPopupLook(
  dark: false,
  surface: Colors.white,
  card: Colors.white,
  field: Color(0x0A000000),
  line: Color(0x14000000),
  accent: Color(0xFFE11D48),
  accent2: Color(0xFFF97316),
  onAccent: Colors.white,
  text: Color(0xFF0B0B0F),
  soft: Color(0xA60B0B0F),
  faint: Color(0x590B0B0F),
);

class _Result<T> {
  T? value;
  bool done = false;
}

/// Opens a picker with [show] from a page (inside [look]'s scope when given)
/// and returns where its answer lands.
Future<_Result<T>> _open<T>(
  WidgetTester tester,
  Future<T?> Function(BuildContext context) show, {
  ThemeData? theme,
  UiPopupLook? look,
  Size size = const Size(900, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final r = _Result<T>();
  Widget page = Builder(
    builder: (ctx) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () async {
            r.value = await show(ctx);
            r.done = true;
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
  if (look != null) page = UiPopupScope(look: look, child: page);
  await tester.pumpWidget(
    MaterialApp(theme: theme ?? GlassTheme.darkTheme, home: page),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return r;
}

Future<void> _tap(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}

Future<void> _key(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

String _header(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('ui_date_header'))).data!;

/// Today in these tests: Friday 9 October 2026.
final _today = DateTime(2026, 10, 9);

Future<DateTime?> Function(BuildContext) _date({
  DateTime? initial,
  DateTime? first,
  DateTime? last,
  String? help,
  SelectableDayPredicate? predicate,
}) =>
    (ctx) => showUiDatePicker(
      context: ctx,
      initialDate: initial ?? _today,
      firstDate: first ?? DateTime(2020),
      lastDate: last ?? DateTime(2030),
      currentDate: _today,
      helpText: help,
      selectableDayPredicate: predicate,
    );

void main() {
  group('showUiDatePicker', () {
    testWidgets('OK gives the picked day with no time; help text shown', (
      tester,
    ) async {
      final r = await _open<DateTime>(
        tester,
        _date(
          initial: DateTime(2026, 10, 9, 10, 30),
          help: 'Select Date of Birth',
        ),
      );
      expect(find.byKey(const Key('ui_date_picker')), findsOneWidget);
      expect(find.text('Select Date of Birth'), findsOneWidget);
      expect(_header(tester), 'Fri, 9 Oct 2026');
      expect(find.text('Today'), findsWidgets); // the chip and the caption
      await _tap(tester, 'ui_date_day_2026-10-21');
      expect(_header(tester), 'Wed, 21 Oct 2026');
      expect(find.text('In 12 days'), findsOneWidget);
      await _tap(tester, 'ui_date_ok');
      expect(r.done, isTrue);
      expect(r.value, DateTime(2026, 10, 21));
      expect(find.byKey(const Key('ui_date_picker')), findsNothing);
    });

    testWidgets(
      'bounds: days outside cannot be picked and the arrows stop at the bounds',
      (tester) async {
        final r = await _open<DateTime>(
          tester,
          _date(
            initial: DateTime(2026, 10, 9),
            first: DateTime(2026, 10, 5),
            last: DateTime(2026, 10, 20, 18),
          ),
        );
        await _tap(tester, 'ui_date_day_2026-10-04');
        await _tap(tester, 'ui_date_day_2026-10-21');
        expect(
          _header(tester),
          'Fri, 9 Oct 2026',
          reason: 'days outside the bounds are not taken',
        );
        expect(
          tester
              .widget<IconButton>(find.byKey(const Key('ui_date_prev')))
              .onPressed,
          isNull,
        );
        expect(
          tester
              .widget<IconButton>(find.byKey(const Key('ui_date_next')))
              .onPressed,
          isNull,
        );
        await _tap(tester, 'ui_date_day_2026-10-20');
        await _tap(tester, 'ui_date_ok');
        expect(r.value, DateTime(2026, 10, 20));
      },
    );

    testWidgets(
      'quick chips: only those inside the bounds; Today jumps to today',
      (tester) async {
        final r = await _open<DateTime>(
          tester,
          _date(
            initial: DateTime(2026, 3, 1),
            first: DateTime(2026),
            last: _today,
          ),
        );
        expect(find.text('March 2026'), findsOneWidget);
        expect(find.byKey(const Key('ui_date_today')), findsOneWidget);
        expect(find.byKey(const Key('ui_date_yesterday')), findsOneWidget);
        expect(find.byKey(const Key('ui_date_tomorrow')), findsNothing);
        expect(find.byKey(const Key('ui_date_next_week')), findsNothing);
        await _tap(tester, 'ui_date_today');
        expect(_header(tester), 'Fri, 9 Oct 2026');
        expect(find.text('October 2026'), findsOneWidget);
        await _tap(tester, 'ui_date_yesterday');
        await _tap(tester, 'ui_date_ok');
        expect(r.value, DateTime(2026, 10, 8));
      },
    );

    testWidgets('+1 week and Tomorrow for an appointment', (tester) async {
      final r = await _open<DateTime>(
        tester,
        _date(first: _today, last: DateTime(2027, 10, 9)),
      );
      expect(find.byKey(const Key('ui_date_yesterday')), findsNothing);
      await _tap(tester, 'ui_date_tomorrow');
      expect(_header(tester), 'Sat, 10 Oct 2026');
      await _tap(tester, 'ui_date_next_week');
      expect(_header(tester), 'Fri, 16 Oct 2026');
      expect(find.text('In 7 days'), findsOneWidget);
      await _tap(tester, 'ui_date_ok');
      expect(r.value, DateTime(2026, 10, 16));
    });

    testWidgets('month arrows: next and previous month, then a day there', (
      tester,
    ) async {
      final r = await _open<DateTime>(tester, _date());
      expect(find.text('October 2026'), findsOneWidget);
      await _tap(tester, 'ui_date_next');
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.byKey(const Key('ui_date_day_2026-10-21')), findsNothing);
      await _tap(tester, 'ui_date_next');
      await _tap(tester, 'ui_date_prev');
      expect(find.text('November 2026'), findsOneWidget);
      await _tap(tester, 'ui_date_day_2026-11-15');
      await _tap(tester, 'ui_date_ok');
      expect(r.value, DateTime(2026, 11, 15));
    });

    testWidgets('Cancel, Esc and a tap outside all give null', (tester) async {
      var r = await _open<DateTime>(tester, _date());
      await _tap(tester, 'ui_date_day_2026-10-21');
      await _tap(tester, 'ui_date_cancel');
      expect(r.done, isTrue);
      expect(r.value, isNull);

      r = await _open<DateTime>(tester, _date());
      await _tap(tester, 'ui_date_day_2026-10-21');
      await _key(tester, LogicalKeyboardKey.escape);
      expect(r.done, isTrue);
      expect(r.value, isNull);
      expect(find.byKey(const Key('ui_date_picker')), findsNothing);

      r = await _open<DateTime>(tester, _date());
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      expect(r.done, isTrue);
      expect(r.value, isNull);
    });

    testWidgets(
      'keyboard: arrows move the day, Page Down the month, Enter is OK',
      (tester) async {
        final r = await _open<DateTime>(tester, _date());
        await _key(tester, LogicalKeyboardKey.arrowRight);
        expect(_header(tester), 'Sat, 10 Oct 2026');
        await _key(tester, LogicalKeyboardKey.arrowDown);
        expect(_header(tester), 'Sat, 17 Oct 2026');
        await _key(tester, LogicalKeyboardKey.arrowLeft);
        await _key(tester, LogicalKeyboardKey.arrowUp);
        expect(_header(tester), 'Fri, 9 Oct 2026');
        await _key(tester, LogicalKeyboardKey.pageDown);
        expect(_header(tester), 'Mon, 9 Nov 2026');
        expect(find.text('November 2026'), findsOneWidget);
        await _key(tester, LogicalKeyboardKey.arrowDown);
        await _key(tester, LogicalKeyboardKey.enter);
        expect(r.done, isTrue);
        expect(r.value, DateTime(2026, 11, 16));
      },
    );

    testWidgets('keyboard stops at the bounds', (tester) async {
      final r = await _open<DateTime>(
        tester,
        _date(first: DateTime(2026, 10, 8), last: DateTime(2026, 10, 12)),
      );
      await _key(tester, LogicalKeyboardKey.arrowDown);
      expect(_header(tester), 'Fri, 9 Oct 2026');
      await _key(tester, LogicalKeyboardKey.arrowLeft);
      await _key(tester, LogicalKeyboardKey.arrowLeft);
      expect(_header(tester), 'Thu, 8 Oct 2026');
      await _key(tester, LogicalKeyboardKey.enter);
      expect(r.value, DateTime(2026, 10, 8));
    });

    testWidgets('year and month grid: a date of birth in a few taps', (
      tester,
    ) async {
      final r = await _open<DateTime>(
        tester,
        _date(
          initial: DateTime(2001, 6, 9),
          first: DateTime(1920),
          last: _today,
        ),
      );
      await _tap(tester, 'ui_date_month_title');
      expect(find.text('Pick a year'), findsOneWidget);
      expect(
        find.byKey(const Key('ui_date_year_2001')),
        findsOneWidget,
        reason: 'opens on the year on show',
      );
      await tester.scrollUntilVisible(
        find.byKey(const Key('ui_date_year_1985')),
        -100,
        scrollable: find.descendant(
          of: find.byKey(const Key('ui_date_years')),
          matching: find.byType(Scrollable),
        ),
      );
      await _tap(tester, 'ui_date_year_1985');
      expect(find.text('1985'), findsOneWidget);
      await _tap(tester, 'ui_date_month_1985-03');
      expect(find.text('March 1985'), findsOneWidget);
      expect(
        _header(tester),
        'Sat, 9 Mar 1985',
        reason: 'the same day in the month picked',
      );
      await _tap(tester, 'ui_date_day_1985-03-14');
      expect(find.text('41 years ago'), findsOneWidget);
      await _tap(tester, 'ui_date_ok');
      expect(r.value, DateTime(1985, 3, 14));
    });

    testWidgets('month grid: months past the bounds cannot be picked', (
      tester,
    ) async {
      await _open<DateTime>(
        tester,
        _date(first: DateTime(2026, 2, 10), last: _today),
      );
      await _tap(tester, 'ui_date_month_title');
      await _tap(tester, 'ui_date_year_2026');
      await _tap(tester, 'ui_date_month_2026-11');
      await _tap(tester, 'ui_date_month_2026-01');
      expect(
        find.text('2026'),
        findsOneWidget,
        reason: 'still on the month grid',
      );
      await _tap(tester, 'ui_date_month_2026-02');
      expect(find.text('February 2026'), findsOneWidget);
    });

    testWidgets(
      'typing a date: dd/mm/yyyy, two-digit years, and plain-word problems',
      (tester) async {
        final r = await _open<DateTime>(
          tester,
          _date(first: DateTime(1920), last: _today),
        );
        await _tap(tester, 'ui_date_type');
        expect(find.byKey(const Key('ui_date_input')), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('ui_date_input')),
          '31/02/2020',
        );
        await tester.pumpAndSettle();
        expect(find.text('Type the date as dd/mm/yyyy'), findsOneWidget);
        expect(
          tester
              .widget<TextButton>(find.byKey(const Key('ui_date_ok')))
              .onPressed,
          isNull,
        );
        await tester.enterText(
          find.byKey(const Key('ui_date_input')),
          '01/01/2027',
        );
        await tester.pumpAndSettle();
        expect(
          find.text('Pick a day from 1 Jan 1920 to 9 Oct 2026'),
          findsOneWidget,
        );
        await tester.enterText(
          find.byKey(const Key('ui_date_input')),
          '14-3-85',
        );
        await tester.pumpAndSettle();
        expect(
          find.text('March 1985'),
          findsOneWidget,
          reason: 'the calendar follows what is typed',
        );
        await _tap(tester, 'ui_date_type');
        expect(_header(tester), 'Thu, 14 Mar 1985');
        await _tap(tester, 'ui_date_type');
        await tester.enterText(
          find.byKey(const Key('ui_date_input')),
          '05.11.2001',
        );
        await tester.pumpAndSettle();
        await _tap(tester, 'ui_date_ok');
        expect(r.value, DateTime(2001, 11, 5));
      },
    );

    testWidgets('selectableDayPredicate: days it refuses cannot be picked', (
      tester,
    ) async {
      final r = await _open<DateTime>(
        tester,
        _date(predicate: (d) => d.weekday != DateTime.sunday),
      );
      await _tap(tester, 'ui_date_day_2026-10-11');
      expect(_header(tester), 'Fri, 9 Oct 2026');
      await _key(tester, LogicalKeyboardKey.arrowRight);
      await _key(tester, LogicalKeyboardKey.arrowRight);
      expect(
        _header(tester),
        'Mon, 12 Oct 2026',
        reason: 'the keys step over the Sunday',
      );
      await _tap(tester, 'ui_date_ok');
      expect(r.value, DateTime(2026, 10, 12));
    });

    testWidgets('pickDate opens the new picker with the record\'s own day', (
      tester,
    ) async {
      final record = DateTime(2012, 4, 3, 15);
      final r = await _open<DateTime>(
        tester,
        (ctx) => pickDate(ctx, initial: record),
      );
      expect(find.byKey(const Key('ui_date_picker')), findsOneWidget);
      expect(find.byType(DatePickerDialog), findsNothing);
      expect(_header(tester), 'Tue, 3 Apr 2012');
      await _tap(tester, 'ui_date_ok');
      expect(r.value, DateTime(2012, 4, 3));
    });

    testWidgets(
      'colours: the pop-up look inside the new screens, the theme outside',
      (tester) async {
        Color okStart() {
          final box = tester.widget<DecoratedBox>(
            find
                .ancestor(
                  of: find.byKey(const Key('ui_date_ok')),
                  matching: find.byType(DecoratedBox),
                )
                .first,
          );
          return ((box.decoration as BoxDecoration).gradient! as LinearGradient)
              .colors
              .first;
        }

        await _open<DateTime>(tester, _date(), look: _whiteLook);
        expect(okStart(), _whiteLook.accent);
        expect(
          tester
              .widget<Dialog>(find.byKey(const Key('ui_date_picker')))
              .backgroundColor,
          Colors.white,
        );
        await _tap(tester, 'ui_date_cancel');

        await _open<DateTime>(tester, _date(), theme: GlassTheme.lightTheme);
        expect(okStart(), GlassTheme.lightTheme.colorScheme.primary);
      },
    );
  });

  group('showUiDateRangePicker', () {
    Future<DateTimeRange?> Function(BuildContext) range({
      DateTimeRange? initial,
      DateTime? first,
    }) =>
        (ctx) => showUiDateRangePicker(
          context: ctx,
          firstDate: first ?? DateTime(1990),
          lastDate: _today,
          currentDate: _today,
          initialDateRange: initial,
        );

    testWidgets('opens on the range given; two taps pick a new one', (
      tester,
    ) async {
      final r = await _open<DateTimeRange>(
        tester,
        range(
          initial: DateTimeRange(
            start: DateTime(2026, 9, 10),
            end: DateTime(2026, 10, 2, 23),
          ),
        ),
      );
      expect(find.byKey(const Key('ui_date_range_picker')), findsOneWidget);
      expect(_header(tester), '10 Sep – 2 Oct 2026');
      expect(find.text('23 days'), findsOneWidget);
      await _tap(tester, 'ui_date_day_2026-10-02');
      expect(find.text('Now pick the last day'), findsOneWidget);
      await _tap(tester, 'ui_date_day_2026-10-06');
      expect(_header(tester), '2 Oct – 6 Oct 2026');
      await _tap(tester, 'ui_date_ok');
      expect(
        r.value,
        DateTimeRange(start: DateTime(2026, 10, 2), end: DateTime(2026, 10, 6)),
      );
    });

    testWidgets(
      'a day before the first starts again; OK with one day gives that day',
      (tester) async {
        final r = await _open<DateTimeRange>(tester, range());
        expect(_header(tester), 'Pick the first day');
        expect(
          tester
              .widget<TextButton>(find.byKey(const Key('ui_date_ok')))
              .onPressed,
          isNull,
        );
        await _tap(tester, 'ui_date_day_2026-10-06');
        await _tap(tester, 'ui_date_day_2026-10-03');
        expect(find.text('Now pick the last day'), findsOneWidget);
        await _tap(
          tester,
          'ui_date_day_2026-10-12',
        ); // after the last date: not taken
        await _tap(tester, 'ui_date_ok');
        expect(
          r.value,
          DateTimeRange(
            start: DateTime(2026, 10, 3),
            end: DateTime(2026, 10, 3),
          ),
        );
      },
    );

    testWidgets('chips: Last 7 days, Last 30 days, This month, Last month', (
      tester,
    ) async {
      var r = await _open<DateTimeRange>(tester, range());
      await _tap(tester, 'ui_range_last7');
      expect(_header(tester), '3 Oct – 9 Oct 2026');
      await _tap(tester, 'ui_range_last30');
      expect(_header(tester), '10 Sep – 9 Oct 2026');
      await _tap(tester, 'ui_range_this_month');
      expect(_header(tester), '1 Oct – 9 Oct 2026');
      await _tap(tester, 'ui_range_last_month');
      expect(_header(tester), '1 Sep – 30 Sep 2026');
      expect(find.text('September 2026'), findsOneWidget);
      await _tap(tester, 'ui_date_ok');
      expect(
        r.value,
        DateTimeRange(start: DateTime(2026, 9, 1), end: DateTime(2026, 9, 30)),
      );

      r = await _open<DateTimeRange>(
        tester,
        range(first: DateTime(2026, 9, 20)),
      );
      expect(find.byKey(const Key('ui_range_last7')), findsOneWidget);
      expect(find.byKey(const Key('ui_range_last30')), findsNothing);
      expect(find.byKey(const Key('ui_range_last_month')), findsNothing);
      await _tap(tester, 'ui_date_cancel');
      expect(r.value, isNull);
    });

    testWidgets(
      'keyboard: arrows move, Space picks, Enter is OK, Esc cancels',
      (tester) async {
        var r = await _open<DateTimeRange>(
          tester,
          range(
            initial: DateTimeRange(
              start: DateTime(2026, 10, 1),
              end: DateTime(2026, 10, 5),
            ),
          ),
        );
        await _key(tester, LogicalKeyboardKey.arrowLeft); // 4 Oct
        await _key(tester, LogicalKeyboardKey.space);
        await _key(tester, LogicalKeyboardKey.arrowRight);
        await _key(tester, LogicalKeyboardKey.arrowRight); // 6 Oct
        await _key(tester, LogicalKeyboardKey.space);
        expect(_header(tester), '4 Oct – 6 Oct 2026');
        await _key(tester, LogicalKeyboardKey.enter);
        expect(
          r.value,
          DateTimeRange(
            start: DateTime(2026, 10, 4),
            end: DateTime(2026, 10, 6),
          ),
        );

        r = await _open<DateTimeRange>(tester, range());
        await _key(tester, LogicalKeyboardKey.escape);
        expect(r.done, isTrue);
        expect(r.value, isNull);
      },
    );

    testWidgets('typing a range', (tester) async {
      final r = await _open<DateTimeRange>(tester, range());
      await _tap(tester, 'ui_date_type');
      await tester.enterText(
        find.byKey(const Key('ui_date_input')),
        '05/10/2026',
      );
      await tester.enterText(
        find.byKey(const Key('ui_date_input_to')),
        '01/10/2026',
      );
      await tester.pumpAndSettle();
      expect(find.text('The last day is before the first day'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('ui_date_input_to')),
        '08/10/2026',
      );
      await tester.pumpAndSettle();
      await _tap(tester, 'ui_date_ok');
      expect(
        r.value,
        DateTimeRange(start: DateTime(2026, 10, 5), end: DateTime(2026, 10, 8)),
      );
    });
  });

  group('showUiTimePicker', () {
    Future<TimeOfDay?> Function(BuildContext) time(TimeOfDay initial) =>
        (ctx) => showUiTimePicker(
          context: ctx,
          initialTime: initial,
          currentTime: DateTime(2026, 10, 9, 15, 7),
        );

    String shown(WidgetTester tester) {
      String part(String key) => tester
          .widget<Text>(
            find.descendant(
              of: find.byKey(Key(key)),
              matching: find.byType(Text),
            ),
          )
          .data!;
      final pm = tester.widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(const Key('ui_time_pm')),
          matching: find.byType(AnimatedContainer),
        ),
      );
      final isPm = (pm.decoration! as BoxDecoration).gradient != null;
      return '${part('ui_time_hour')}:${part('ui_time_minute')} ${isPm ? 'PM' : 'AM'}';
    }

    testWidgets('tap the hour, then the minutes, then PM', (tester) async {
      final r = await _open<TimeOfDay>(
        tester,
        time(const TimeOfDay(hour: 10, minute: 30)),
      );
      expect(find.byKey(const Key('ui_time_picker')), findsOneWidget);
      expect(shown(tester), '10:30 AM');
      expect(find.text('Hour'), findsOneWidget);
      await _tap(tester, 'ui_time_h_3');
      expect(
        find.text('Minutes'),
        findsOneWidget,
        reason: 'the minutes follow the hour',
      );
      await _tap(tester, 'ui_time_m_45');
      await _tap(tester, 'ui_time_pm');
      expect(shown(tester), '3:45 PM');
      await _tap(tester, 'ui_time_ok');
      expect(r.value, const TimeOfDay(hour: 15, minute: 45));
    });

    testWidgets('the small arrows step across noon and midnight; Now', (
      tester,
    ) async {
      final r = await _open<TimeOfDay>(
        tester,
        time(const TimeOfDay(hour: 11, minute: 59)),
      );
      await _tap(tester, 'ui_time_minute_up');
      expect(shown(tester), '12:00 PM');
      await _tap(tester, 'ui_time_hour_down');
      await _tap(tester, 'ui_time_hour_down');
      expect(shown(tester), '10:00 AM');
      await _tap(tester, 'ui_time_now');
      expect(shown(tester), '3:07 PM');
      await _tap(tester, 'ui_time_ok');
      expect(r.value, const TimeOfDay(hour: 15, minute: 7));

      final r2 = await _open<TimeOfDay>(
        tester,
        time(const TimeOfDay(hour: 0, minute: 0)),
      );
      expect(shown(tester), '12:00 AM');
      await _tap(tester, 'ui_time_minute_down');
      expect(shown(tester), '11:59 PM');
      await _tap(tester, 'ui_time_ok');
      expect(r2.value, const TimeOfDay(hour: 23, minute: 59));
    });

    testWidgets(
      'keyboard: digits type the time, arrows step, P for PM, Enter is OK',
      (tester) async {
        final r = await _open<TimeOfDay>(
          tester,
          time(const TimeOfDay(hour: 9, minute: 5)),
        );
        await _key(tester, LogicalKeyboardKey.digit1);
        await _key(tester, LogicalKeyboardKey.digit1);
        await _key(tester, LogicalKeyboardKey.digit4);
        await _key(tester, LogicalKeyboardKey.digit0);
        expect(shown(tester), '11:40 AM');
        await _key(tester, LogicalKeyboardKey.arrowUp);
        expect(shown(tester), '11:41 AM');
        await _key(tester, LogicalKeyboardKey.arrowLeft);
        await _key(tester, LogicalKeyboardKey.arrowDown);
        expect(shown(tester), '10:41 AM');
        await _key(tester, LogicalKeyboardKey.keyP);
        await _key(tester, LogicalKeyboardKey.enter);
        expect(r.value, const TimeOfDay(hour: 22, minute: 41));
      },
    );

    testWidgets('Cancel and Esc give null', (tester) async {
      var r = await _open<TimeOfDay>(
        tester,
        time(const TimeOfDay(hour: 9, minute: 0)),
      );
      await _tap(tester, 'ui_time_h_4');
      await _tap(tester, 'ui_time_cancel');
      expect(r.done, isTrue);
      expect(r.value, isNull);
      r = await _open<TimeOfDay>(
        tester,
        time(const TimeOfDay(hour: 9, minute: 0)),
      );
      await _key(tester, LogicalKeyboardKey.escape);
      expect(r.done, isTrue);
      expect(r.value, isNull);
    });
  });

  final looks = <String, (UiPopupLook?, ThemeData?)>{
    'dark': (_darkLook, null),
    'light': (_lightLook, GlassTheme.lightTheme),
    'black': (_blackLook, null),
    'white': (_whiteLook, GlassTheme.lightTheme),
    'no scope dark': (null, GlassTheme.darkTheme),
    'no scope light': (null, GlassTheme.lightTheme),
    'no scope plain': (null, ThemeData()),
  };
  for (final size in const [Size(320, 640), Size(1440, 900)]) {
    for (final look in looks.entries) {
      testWidgets('fits ${size.width.toInt()} wide, ${look.key}', (
        tester,
      ) async {
        void fits(String what) {
          expect(tester.takeException(), isNull, reason: what);
          final rect = tester.getRect(
            find
                .descendant(
                  of: find.byType(Dialog),
                  matching: find.byType(Material),
                )
                .first,
          );
          expect(
            rect.left >= 0 &&
                rect.right <= size.width &&
                rect.top >= 0 &&
                rect.bottom <= size.height,
            isTrue,
            reason: '$what: $rect',
          );
          if (size.width < 400)
            expect(
              rect.width,
              greaterThanOrEqualTo(size.width - 24),
              reason: '$what: full width',
            );
          if (size.width > 400)
            expect(
              rect.width,
              lessThanOrEqualTo(342),
              reason: '$what: compact',
            );
        }

        await _open<DateTime>(
          tester,
          _date(help: 'Select Date of Birth', first: DateTime(1900)),
          look: look.value.$1,
          theme: look.value.$2,
          size: size,
        );
        fits('date');
        await _tap(tester, 'ui_date_day_2026-10-21');
        await _tap(tester, 'ui_date_month_title');
        fits('years');
        await _tap(tester, 'ui_date_year_2026');
        fits('months');
        await _tap(tester, 'ui_date_month_2026-08');
        await _tap(tester, 'ui_date_type');
        await tester.enterText(
          find.byKey(const Key('ui_date_input')),
          '99/99/9999',
        );
        await tester.pumpAndSettle();
        fits('typing');
        await _tap(tester, 'ui_date_cancel');

        await _open<DateTimeRange>(
          tester,
          (ctx) => showUiDateRangePicker(
            context: ctx,
            firstDate: DateTime(1990),
            lastDate: _today,
            currentDate: _today,
            initialDateRange: DateTimeRange(
              start: DateTime(2025, 12, 28),
              end: DateTime(2026, 1, 3),
            ),
          ),
          look: look.value.$1,
          theme: look.value.$2,
          size: size,
        );
        fits('range');
        await _tap(tester, 'ui_date_type');
        await tester.enterText(
          find.byKey(const Key('ui_date_input_to')),
          '1/1/1',
        );
        await tester.pumpAndSettle();
        fits('range typing');
        await _tap(tester, 'ui_date_cancel');

        await _open<TimeOfDay>(
          tester,
          (ctx) => showUiTimePicker(
            context: ctx,
            initialTime: const TimeOfDay(hour: 12, minute: 55),
          ),
          look: look.value.$1,
          theme: look.value.$2,
          size: size,
        );
        fits('time');
        await _tap(tester, 'ui_time_minute');
        fits('time minutes');
        await _tap(tester, 'ui_time_cancel');
      });
    }
  }

  testWidgets('large text stays inside the window', (tester) async {
    tester.view.physicalSize = const Size(360, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    DateTime? got;
    await tester.pumpWidget(
      MaterialApp(
        theme: GlassTheme.darkTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Builder(
          builder: (ctx) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async => got = await showUiDatePicker(
                  context: ctx,
                  initialDate: _today,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  currentDate: _today,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const Key('ui_date_ok')));
    await tester.pumpAndSettle();
    await _tap(tester, 'ui_date_ok');
    expect(got, _today);
  });
}
