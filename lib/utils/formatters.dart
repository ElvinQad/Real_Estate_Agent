import 'package:intl/intl.dart';

class Formatters {
  static final currencyFormatter = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 0,
  );

  static String formatPrice(double price) {
    return currencyFormatter.format(price);
  }
}
