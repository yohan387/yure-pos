import 'package:flutter/material.dart';
import 'package:todouapp/features/payments/presentation/pages/stripe_payment_page.dart';

class PaymentHelper {
  // static Future<bool> launchStripePayment(
  //     BuildContext context, double amount) async {
  //   final result = await Navigator.of(context).push<bool>(
  //     MaterialPageRoute<bool>(
  //       builder: (context) => StripePaymentPage(amount: amount),
  //     ),
  //   );
  //   return result ?? false;
  // }

  static Future<void> launchStripePayment(
      BuildContext context, double amount) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => StripePaymentPage(amount: amount),
      ),
    );
  }
}
