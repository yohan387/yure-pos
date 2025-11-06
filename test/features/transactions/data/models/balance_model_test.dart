import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/features/transactions/data/models/balance_model.dart';

void main() {
  group('BalanceModel', () {
    final tBalanceModel = BalanceModel(
      amount: 1250000.0,
      currency: 'XOF',
    );

    final tJson = {
      'total_balance': 1250000,
      'currency': 'XOF',
    };

    group('fromJson', () {
      test('should return a valid BalanceModel from complete JSON', () {
        // act
        final result = BalanceModel.fromJson(tJson);

        // assert
        expect(result.amount, equals(1250000.0));
        expect(result.currency, equals('XOF'));
      });

      test('should convert int total_balance to double', () {
        // arrange
        final jsonWithInt = {'total_balance': 1250000, 'currency': 'XOF'};

        // act
        final result = BalanceModel.fromJson(jsonWithInt);

        // assert
        expect(result.amount, isA<double>());
        expect(result.amount, equals(1250000.0));
      });

      test('should convert double total_balance correctly', () {
        // arrange
        final jsonWithDouble = {'total_balance': 1250000.75, 'currency': 'XOF'};

        // act
        final result = BalanceModel.fromJson(jsonWithDouble);

        // assert
        expect(result.amount, equals(1250000.75));
      });

      test('should handle null currency with "Fcfa" default', () {
        // arrange
        final jsonWithNullCurrency = {'total_balance': 1250000, 'currency': null};

        // act
        final result = BalanceModel.fromJson(jsonWithNullCurrency);

        // assert
        expect(result.currency, equals('Fcfa'));
      });

      test('should handle missing currency with "Fcfa" default', () {
        // arrange
        final jsonWithoutCurrency = {'total_balance': 1250000};

        // act
        final result = BalanceModel.fromJson(jsonWithoutCurrency);

        // assert
        expect(result.currency, equals('Fcfa'));
      });

      test('should handle zero balance', () {
        // arrange
        final jsonWithZero = {'total_balance': 0, 'currency': 'XOF'};

        // act
        final result = BalanceModel.fromJson(jsonWithZero);

        // assert
        expect(result.amount, equals(0.0));
      });

      test('should handle negative balance', () {
        // arrange
        final jsonWithNegative = {'total_balance': -5000, 'currency': 'XOF'};

        // act
        final result = BalanceModel.fromJson(jsonWithNegative);

        // assert
        expect(result.amount, equals(-5000.0));
      });

      test('should handle large balance amounts', () {
        // arrange
        final jsonWithLarge = {'total_balance': 999999999.99, 'currency': 'XOF'};

        // act
        final result = BalanceModel.fromJson(jsonWithLarge);

        // assert
        expect(result.amount, equals(999999999.99));
      });
    });
  });
}
