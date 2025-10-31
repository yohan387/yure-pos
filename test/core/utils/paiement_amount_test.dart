import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/core/utils/paiement_amount.dart';

void main() {
  group('PaiementMontant - convertToStripeAmount', () {
    test('converts EUR amount correctly (100 centimes per euro)', () {
      final result = PaiementMontant.convertToStripeAmount(10.50, 'EUR');

      expect(result, 1050); // 10.50 EUR = 1050 centimes
    });

    test('converts USD amount correctly (100 cents per dollar)', () {
      final result = PaiementMontant.convertToStripeAmount(25.99, 'USD');

      expect(result, 2599); // 25.99 USD = 2599 cents
    });

    test('converts XOF amount correctly (zero-decimal currency)', () {
      final result = PaiementMontant.convertToStripeAmount(5000, 'XOF');

      expect(result, 5000); // XOF has no decimal places
    });

    test('converts JPY amount correctly (zero-decimal currency)', () {
      final result = PaiementMontant.convertToStripeAmount(1000, 'JPY');

      expect(result, 1000); // JPY has no decimal places
    });

    test('converts VND amount correctly (zero-decimal currency)', () {
      final result = PaiementMontant.convertToStripeAmount(50000, 'VND');

      expect(result, 50000); // VND has no decimal places
    });

    test('handles fractional amounts for decimal currencies', () {
      final result = PaiementMontant.convertToStripeAmount(9.99, 'EUR');

      expect(result, 999);
    });

    test('handles zero amount', () {
      final result = PaiementMontant.convertToStripeAmount(0, 'EUR');

      expect(result, 0);
    });

    test('handles large amounts for EUR', () {
      final result = PaiementMontant.convertToStripeAmount(999999.99, 'EUR');

      expect(result, 99999999);
    });
  });

  group('PaiementMontant - convertFromStripeAmount', () {
    test('converts EUR amount from centimes correctly', () {
      final result = PaiementMontant.convertFromStripeAmount(1050, 'EUR');

      expect(result, 10.50);
    });

    test('converts USD amount from cents correctly', () {
      final result = PaiementMontant.convertFromStripeAmount(2599, 'USD');

      expect(result, 25.99);
    });

    test('converts XOF amount correctly (zero-decimal currency)', () {
      final result = PaiementMontant.convertFromStripeAmount(5000, 'XOF');

      expect(result, 5000.0);
    });

    test('converts JPY amount correctly (zero-decimal currency)', () {
      final result = PaiementMontant.convertFromStripeAmount(1000, 'JPY');

      expect(result, 1000.0);
    });

    test('converts VND amount correctly (zero-decimal currency)', () {
      final result = PaiementMontant.convertFromStripeAmount(50000, 'VND');

      expect(result, 50000.0);
    });

    test('handles zero amount', () {
      final result = PaiementMontant.convertFromStripeAmount(0, 'EUR');

      expect(result, 0.0);
    });

    test('handles single centime', () {
      final result = PaiementMontant.convertFromStripeAmount(1, 'EUR');

      expect(result, 0.01);
    });
  });

  group('PaiementMontant - Round trip conversion', () {
    test('EUR amount survives round trip conversion', () {
      const originalAmount = 42.75;
      final stripeAmount =
          PaiementMontant.convertToStripeAmount(originalAmount, 'EUR');
      final convertedBack =
          PaiementMontant.convertFromStripeAmount(stripeAmount, 'EUR');

      expect(convertedBack, originalAmount);
    });

    test('XOF amount survives round trip conversion', () {
      const originalAmount = 10000.0;
      final stripeAmount =
          PaiementMontant.convertToStripeAmount(originalAmount, 'XOF');
      final convertedBack =
          PaiementMontant.convertFromStripeAmount(stripeAmount, 'XOF');

      expect(convertedBack, originalAmount);
    });

    test('USD amount survives round trip conversion', () {
      const originalAmount = 100.50;
      final stripeAmount =
          PaiementMontant.convertToStripeAmount(originalAmount, 'USD');
      final convertedBack =
          PaiementMontant.convertFromStripeAmount(stripeAmount, 'USD');

      expect(convertedBack, originalAmount);
    });
  });
}
