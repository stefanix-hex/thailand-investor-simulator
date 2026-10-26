import 'package:intl/intl.dart';

final eur0 = NumberFormat.currency(locale: 'en_IE', symbol: '€', decimalDigits: 0);
final eur2 = NumberFormat.currency(locale: 'en_IE', symbol: '€', decimalDigits: 2);
final pct1 = NumberFormat.percentPattern()..maximumFractionDigits = 1;
final pct0 = NumberFormat.percentPattern()..maximumFractionDigits = 0;
final num1 = NumberFormat('#,##0.0');

String money(double v) => eur0.format(v);
String ratio(double v) => v.isFinite ? v.toStringAsFixed(2) : '—';
String percent(double v) => '${(v * 100).toStringAsFixed(1)}%';
