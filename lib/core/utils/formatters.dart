import 'package:intl/intl.dart';

String formatMoney(double value, {String currencySymbol = ''}) {
  final formatted = NumberFormat.decimalPattern().format(value.round());
  if (currencySymbol.isEmpty) return formatted;
  return '$currencySymbol $formatted';
}
