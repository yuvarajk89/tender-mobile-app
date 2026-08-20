import 'package:intl/intl.dart';

/// Central formatting so carats, money and dates look identical everywhere.
class Fmt {
  Fmt._();

  static final NumberFormat _money0 = NumberFormat.currency(
      locale: 'en_US', symbol: '\$', decimalDigits: 0);
  static final NumberFormat _money2 = NumberFormat.currency(
      locale: 'en_US', symbol: '\$', decimalDigits: 2);
  static final NumberFormat _ct = NumberFormat('#,##0.00');
  static final NumberFormat _pct = NumberFormat('#,##0.##');
  static final DateFormat _date = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTime = DateFormat('dd MMM, HH:mm');

  /// $3,192 — for headline figures (bid, break-even).
  static String money(num v) => _money0.format(v);

  /// $3,191.75 — where the cents matter.
  static String money2(num v) => _money2.format(v);

  /// 39.39 ct
  static String carats(num v) => '${_ct.format(v)} ct';

  /// 11% (drops trailing zeros)
  static String percent(num v) => '${_pct.format(v)}%';

  static String date(DateTime d) => _date.format(d);
  static String dateTime(DateTime d) => _dateTime.format(d);
}
