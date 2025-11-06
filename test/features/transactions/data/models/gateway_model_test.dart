import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/features/transactions/data/models/gateway_model.dart';

void main() {
  group('GatewayModel', () {
    test('should create a GatewayModel with valid data', () {
      // arrange
      const imageUrl = 'https://example.com/orange_money.png';
      const name = 'Orange Money';

      // act
      final result = GatewayModel(
        imageUrl: imageUrl,
        name: name,
      );

      // assert
      expect(result.imageUrl, equals(imageUrl));
      expect(result.name, equals(name));
    });

    test('should create GatewayModel with empty strings', () {
      // act
      final result = GatewayModel(
        imageUrl: '',
        name: '',
      );

      // assert
      expect(result.imageUrl, equals(''));
      expect(result.name, equals(''));
    });

    test('should create GatewayModel for Orange Money', () {
      // act
      final result = GatewayModel(
        imageUrl: 'assets/images/orange_money.png',
        name: 'Orange Money',
      );

      // assert
      expect(result.name, equals('Orange Money'));
      expect(result.imageUrl, contains('orange_money'));
    });

    test('should create GatewayModel for Wave', () {
      // act
      final result = GatewayModel(
        imageUrl: 'assets/images/wave.png',
        name: 'Wave',
      );

      // assert
      expect(result.name, equals('Wave'));
      expect(result.imageUrl, contains('wave'));
    });

    test('should create GatewayModel for Stripe', () {
      // act
      final result = GatewayModel(
        imageUrl: 'assets/images/stripe.png',
        name: 'Stripe',
      );

      // assert
      expect(result.name, equals('Stripe'));
      expect(result.imageUrl, contains('stripe'));
    });

    test('should allow special characters in imageUrl and name', () {
      // act
      final result = GatewayModel(
        imageUrl: 'https://example.com/image?id=123&type=png',
        name: 'Payment Gateway #1 (Main)',
      );

      // assert
      expect(result.imageUrl, contains('?'));
      expect(result.imageUrl, contains('&'));
      expect(result.name, contains('#'));
      expect(result.name, contains('('));
    });
  });
}
