import 'package:intl/intl.dart';

final NumberFormat _amountFormat = NumberFormat('#,##0.##', 'en_US');

String formatCurrency(num amount) {
  return '৳ ${_amountFormat.format(amount)}';
}

String formatCompactCurrency(num amount) {
  if (amount >= 10000000) return '৳ ${(amount / 10000000).toStringAsFixed(1)}Cr';
  if (amount >= 100000) return '৳ ${(amount / 100000).toStringAsFixed(1)}L';
  if (amount >= 1000) return '৳ ${(amount / 1000).toStringAsFixed(1)}k';
  return formatCurrency(amount);
}

String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
String formatShortDate(DateTime date) => DateFormat('dd MMM').format(date);
String formatMonthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);
String formatWeekday(DateTime date) => DateFormat('E').format(date);
