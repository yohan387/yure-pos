class PaiementMontant {
  static int convertToStripeAmount(double montant, String currency) {
    final zeroDecimalCurrencies = ['XOF', 'JPY', 'VND'];

    return zeroDecimalCurrencies.contains(currency.toUpperCase())
        ? montant.round()
        : (montant * 100).round();
  }

  static double convertFromStripeAmount(int amount, String currency) {
    final zeroDecimalCurrencies = ['XOF', 'JPY', 'VND'];

    return zeroDecimalCurrencies.contains(currency.toUpperCase())
        ? amount.toDouble()
        : amount / 100.0;
  }
}
