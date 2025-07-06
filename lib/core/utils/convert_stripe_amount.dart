class ConvertStripeAmount {
  static int convertToStripeAmount(double montantEuro) {
    return (montantEuro * 100).round();
  }

  static double convertFromStripeAmount(dynamic montant, String currency) {
    final zeroDecimalCurrencies = ['XOF', 'JPY', 'VND'];

    if (montant is! num) {
      throw ArgumentError('Le montant doit être un int ou un double.');
    }

    if (zeroDecimalCurrencies.contains(currency.toUpperCase())) {
      return montant.toDouble();
    } else {
      return montant.toDouble() / 100.0;
    }
  }

  static String formatMontant(double montantEuro) {
    return '${montantEuro.toStringAsFixed(2)} €';
  }
}
