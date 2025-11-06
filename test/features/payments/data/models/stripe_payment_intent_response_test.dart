import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/features/payments/data/models/stripe_payment_intent_response.dart';

void main() {
  group('StripePaymentIntentResponse', () {
    group('fromJson', () {
      test('should create valid instance from JSON with client_secret', () {
        // Arrange
        final json = {
          'client_secret': 'pi_test_secret_123456',
        };

        // Act
        final result = StripePaymentIntentResponse.fromJson(json);

        // Assert
        expect(result, isA<StripePaymentIntentResponse>());
        expect(result.clientSecret, 'pi_test_secret_123456');
      });

      test('should handle empty client_secret', () {
        // Arrange
        final json = {
          'client_secret': '',
        };

        // Act
        final result = StripePaymentIntentResponse.fromJson(json);

        // Assert
        expect(result.clientSecret, '');
      });

      test('should throw when client_secret is null', () {
        // Arrange
        final json = <String, dynamic>{
          'client_secret': null,
        };

        // Act & Assert
        expect(
          () => StripePaymentIntentResponse.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });

      test('should throw when client_secret is missing', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act & Assert
        expect(
          () => StripePaymentIntentResponse.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        // Arrange
        final response = StripePaymentIntentResponse(
          clientSecret: 'pi_test_secret_123456',
        );

        // Act
        final json = response.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['client_secret'], 'pi_test_secret_123456');
        expect(json.length, 1);
      });

      test('should convert empty clientSecret to JSON', () {
        // Arrange
        final response = StripePaymentIntentResponse(
          clientSecret: '',
        );

        // Act
        final json = response.toJson();

        // Assert
        expect(json['client_secret'], '');
      });
    });

    group('constructor', () {
      test('should create instance with required clientSecret', () {
        // Act
        final response = StripePaymentIntentResponse(
          clientSecret: 'pi_test_secret',
        );

        // Assert
        expect(response.clientSecret, 'pi_test_secret');
      });
    });
  });

  group('StripeLinkPaymentInitRequest', () {
    group('constructor', () {
      test('should create instance with all required fields', () {
        // Act
        final request = StripeLinkPaymentInitRequest(
          amount: 10000,
          currency: 'XOF',
          terminalId: 1,
          merchantId: 123,
        );

        // Assert
        expect(request.amount, 10000);
        expect(request.currency, 'XOF');
        expect(request.terminalId, 1);
        expect(request.merchantId, 123);
      });

      test('should accept dynamic amount type (int)', () {
        // Act
        final request = StripeLinkPaymentInitRequest(
          amount: 50000,
          currency: 'USD',
          terminalId: 2,
          merchantId: 456,
        );

        // Assert
        expect(request.amount, isA<int>());
        expect(request.amount, 50000);
      });

      test('should accept dynamic amount type (double)', () {
        // Act
        final request = StripeLinkPaymentInitRequest(
          amount: 100.50,
          currency: 'EUR',
          terminalId: 3,
          merchantId: 789,
        );

        // Assert
        expect(request.amount, isA<double>());
        expect(request.amount, 100.50);
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly with int amount', () {
        // Arrange
        final request = StripeLinkPaymentInitRequest(
          amount: 25000,
          currency: 'XOF',
          terminalId: 10,
          merchantId: 999,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json, isA<Map<String, dynamic>>());
        expect(json['amount'], 25000);
        expect(json['currency'], 'XOF');
        expect(json['terminal_id'], 10);
        expect(json['merchant_id'], 999);
        expect(json.length, 4);
      });

      test('should convert to JSON correctly with double amount', () {
        // Arrange
        final request = StripeLinkPaymentInitRequest(
          amount: 150.75,
          currency: 'USD',
          terminalId: 5,
          merchantId: 200,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json['amount'], 150.75);
        expect(json['currency'], 'USD');
        expect(json['terminal_id'], 5);
        expect(json['merchant_id'], 200);
      });

      test('should use snake_case for terminal_id and merchant_id', () {
        // Arrange
        final request = StripeLinkPaymentInitRequest(
          amount: 1000,
          currency: 'XOF',
          terminalId: 1,
          merchantId: 1,
        );

        // Act
        final json = request.toJson();

        // Assert
        expect(json.containsKey('terminal_id'), true);
        expect(json.containsKey('merchant_id'), true);
        expect(json.containsKey('terminalId'), false);
        expect(json.containsKey('merchantId'), false);
      });
    });
  });

  group('StripeLinkToPayResponse', () {
    group('fromJson', () {
      test('should create valid instance from JSON', () {
        // Arrange
        final json = {
          'payment_link': 'https://stripe.com/payment/link123',
          'transaction_ref': 'txn_abc123',
        };

        // Act
        final result = StripeLinkToPayResponse.fromJson(json);

        // Assert
        expect(result, isA<StripeLinkToPayResponse>());
        expect(result.paymentLink, 'https://stripe.com/payment/link123');
        expect(result.transactionRef, 'txn_abc123');
      });

      test('should use empty string for missing payment_link', () {
        // Arrange
        final json = {
          'transaction_ref': 'txn_xyz789',
        };

        // Act
        final result = StripeLinkToPayResponse.fromJson(json);

        // Assert
        expect(result.paymentLink, '');
        expect(result.transactionRef, 'txn_xyz789');
      });

      test('should use empty string for null payment_link', () {
        // Arrange
        final json = {
          'payment_link': null,
          'transaction_ref': 'txn_def456',
        };

        // Act
        final result = StripeLinkToPayResponse.fromJson(json);

        // Assert
        expect(result.paymentLink, '');
        expect(result.transactionRef, 'txn_def456');
      });

      test('should throw when transaction_ref is null', () {
        // Arrange
        final json = {
          'payment_link': 'https://stripe.com/link',
          'transaction_ref': null,
        };

        // Act & Assert
        expect(
          () => StripeLinkToPayResponse.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });

      test('should throw when transaction_ref is missing', () {
        // Arrange
        final json = {
          'payment_link': 'https://stripe.com/link',
        };

        // Act & Assert
        expect(
          () => StripeLinkToPayResponse.fromJson(json),
          throwsA(isA<TypeError>()),
        );
      });

      test('should handle empty strings', () {
        // Arrange
        final json = {
          'payment_link': '',
          'transaction_ref': '',
        };

        // Act
        final result = StripeLinkToPayResponse.fromJson(json);

        // Assert
        expect(result.paymentLink, '');
        expect(result.transactionRef, '');
      });
    });

    group('constructor', () {
      test('should create instance with required fields', () {
        // Act
        final response = StripeLinkToPayResponse(
          paymentLink: 'https://stripe.com/pay',
          transactionRef: 'txn_test_123',
        );

        // Assert
        expect(response.paymentLink, 'https://stripe.com/pay');
        expect(response.transactionRef, 'txn_test_123');
      });

      test('should accept empty strings', () {
        // Act
        final response = StripeLinkToPayResponse(
          paymentLink: '',
          transactionRef: '',
        );

        // Assert
        expect(response.paymentLink, '');
        expect(response.transactionRef, '');
      });
    });
  });
}
