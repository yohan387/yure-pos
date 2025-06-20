import 'package:intl/intl.dart';

class AmountFormatter {
  static String format(double amount) {
    // Supprimer les décimales si elles valent 0
    if (amount == amount.roundToDouble()) {
      return NumberFormat("#,##0", "fr_FR").format(amount).replaceAll('\u00A0',
          ' '); // remplace les espaces insécables par des espaces normaux
    } else {
      return NumberFormat("#,##0.##", "fr_FR")
          .format(amount)
          .replaceAll('\u00A0', ' '); // idem
    }
  }
}
