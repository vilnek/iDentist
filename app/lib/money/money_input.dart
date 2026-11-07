import 'package:flutter/services.dart';

/// Seeds a money text field from a stored amount without losing paise.
///
/// The edit dialogs used `amount.toInt().toString()` and
/// `cost.toStringAsFixed(0)`, so opening a ₹1,500.75 payment and pressing Save
/// without touching anything wrote ₹1,500 back. Silent, irreversible, and on
/// every edit of every money field.
///
/// Whole amounts still render as `1500` rather than `1500.00`: they are the
/// overwhelming majority in a clinic, and a trailing `.00` on every field is
/// noise that invites someone to clear it. Paise appear only when there are
/// paise to show.
String moneyFieldText(double amount) {
  if (amount == amount.roundToDouble()) return amount.toStringAsFixed(0);
  return amount.toStringAsFixed(2);
}

/// Restricts a text field to a non-negative amount with at most two decimals.
///
/// The money fields on the patient detail screen carried no `inputFormatters`
/// at all, and `keyboardType: TextInputType.number` is a hint the web and
/// desktop builds ignore. `double.tryParse` then turned `"abc"` into a silent
/// ₹0 and accepted `"-500"` as a negative payment.
///
/// Rejects rather than corrects: a keystroke that would make the field invalid
/// is dropped and the previous value stands, so the caret never jumps.
class MoneyInputFormatter extends TextInputFormatter {
  const MoneyInputFormatter();

  static final RegExp _valid = RegExp(r'^\d*\.?\d{0,2}$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    return _valid.hasMatch(text) ? newValue : oldValue;
  }
}

/// The formatter list every money field on a form should carry.
const List<TextInputFormatter> moneyInputFormatters = [MoneyInputFormatter()];
