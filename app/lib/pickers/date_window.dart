import 'package:flutter/material.dart';

import 'package:identist_app/pickers/date_picker.dart';

/// The window a date picker offers, widened so it always contains the date the
/// record already holds.
///
/// `showDatePicker` asserts `firstDate <= initialDate <= lastDate` and throws
/// when it does not. Every picker on the patient detail screen passed a window
/// derived from *now* alongside an initial date derived from the *record*, so
/// the two drifted apart on their own: editing an appointment older than
/// 30 days, or a visit older than a year, tripped the assert with no bad input
/// from anyone. The payment and discount pickers were pinned to a literal
/// `DateTime(2020)`–`DateTime(2030)`, which fails for every record from
/// 1 January 2031 onward — including new ones, where the default initial date
/// is simply today.
///
/// Widening the bounds is deliberate, rather than clamping the initial date
/// into them. Clamping would open the picker on a date the record does not
/// hold, and the clinician confirming it would silently move a visit they only
/// meant to look at. The record's own date must always be selectable.
@immutable
class DateWindow {
  final DateTime first;
  final DateTime initial;
  final DateTime last;

  const DateWindow._(this.first, this.initial, this.last);

  /// [initial] is the date the record holds. [back] and [forward] are the
  /// window a *new* record should offer, measured from today; both widen if
  /// [initial] falls outside them.
  factory DateWindow.around(
    DateTime initial, {
    Duration back = const Duration(days: 365 * 5),
    Duration forward = const Duration(days: 365 * 5),
  }) {
    final now = DateTime.now();
    var first = now.subtract(back);
    var last = now.add(forward);
    if (initial.isBefore(first)) first = initial;
    if (initial.isAfter(last)) last = initial;
    return DateWindow._(first, initial, last);
  }
}

/// A date picker that cannot assert on its own bounds.
///
/// It opens the app's own themed picker ([showUiDatePicker]), which keeps
/// the same bounds rule.
///
/// Drop-in for `showDatePicker` at call sites that pass a record's date:
/// give it [initial] and the window you want for a new record, and the record's
/// own date is guaranteed to be inside it. See [DateWindow].
Future<DateTime?> pickDate(
  BuildContext context, {
  required DateTime initial,
  Duration back = const Duration(days: 365 * 5),
  Duration forward = const Duration(days: 365 * 5),
}) {
  final window = DateWindow.around(initial, back: back, forward: forward);
  return showUiDatePicker(
    context: context,
    initialDate: window.initial,
    firstDate: window.first,
    lastDate: window.last,
  );
}
