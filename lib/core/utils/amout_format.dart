import 'package:intl/intl.dart';

class AmountFormatter {
  static String format(double amount, {String currency = 'XOF'}) {
    final zeroDecimalCurrencies = ['XOF', 'JPY', 'VND'];

    final format = zeroDecimalCurrencies.contains(currency.toUpperCase())
        ? NumberFormat("#,##0", "fr_FR")
        : NumberFormat("#,##0.##", "fr_FR");

    final formatted = format.format(amount).replaceAll('\u00A0', ' ');

    final symbol = _getSymbol(currency);
    return "$formatted";
  }

  static String _getSymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'XOF':
        return 'FCFA';
      case 'EUR':
        return '€';
      case 'USD':
        return '\$';
      default:
        return currency.toUpperCase();
    }
  }
}
