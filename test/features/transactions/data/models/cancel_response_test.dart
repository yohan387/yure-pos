import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/features/transactions/data/models/cancel_response.dart';

void main() {
  group('CancelPaymentResponse', () {
    final tJson = {
      'message': 'Transaction cancelled successfully',
    };

    group('fromJson', () {
      test('should return a valid CancelPaymentResponse from complete JSON', () {
        // act
        final result = CancelPaymentResponse.fromJson(tJson);

        // assert
        expect(result.message, equals('Transaction cancelled successfully'));
      });

      test('should handle custom message', () {
        // arrange
        final jsonWithCustomMessage = {
          'message': 'Payment has been cancelled by user',
        };

        // act
        final result = CancelPaymentResponse.fromJson(jsonWithCustomMessage);

        // assert
        expect(result.message, equals('Payment has been cancelled by user'));
      });

      test('should handle null message with default value', () {
        // arrange
        final jsonWithNull = {'message': null};

        // act
        final result = CancelPaymentResponse.fromJson(jsonWithNull);

        // assert
        expect(result.message, equals('Transaction cancelled successfully'));
      });

      test('should handle missing message key with default value', () {
        // arrange
        final jsonWithoutMessage = <String, dynamic>{};

        // act
        final result = CancelPaymentResponse.fromJson(jsonWithoutMessage);

        // assert
        expect(result.message, equals('Transaction cancelled successfully'));
      });

      test('should handle empty message string', () {
        // arrange
        final jsonWithEmpty = {'message': ''};

        // act
        final result = CancelPaymentResponse.fromJson(jsonWithEmpty);

        // assert
        expect(result.message, equals(''));
      });
    });
  });
}
