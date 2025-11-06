import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/features/transactions/data/models/transaction_model.dart';
import 'package:todouapp/features/transactions/data/models/transactions_response_model.dart';

void main() {
  group('TransactionsResponseModel', () {
    final tTransaction1Json = {
      'id': 1,
      'merchant_id': 100,
      'terminal_id': 200,
      'amount': 5000,
      'currency': 'XOF',
      'transaction_ref': 'TXN001',
      'created_at': '2024-01-15T10:30:00.000Z',
      'payment_method': 'Mobile Money',
      'status': 'success',
      'customer_phone': '+221771234567',
      'network': 'Orange Money',
    };

    final tTransaction2Json = {
      'id': 2,
      'merchant_id': 100,
      'terminal_id': 200,
      'amount': 3000,
      'currency': 'XOF',
      'transaction_ref': 'TXN002',
      'created_at': '2024-01-15T11:30:00.000Z',
      'payment_method': 'Card',
      'status': 'pending',
      'customer_phone': '+221771234568',
      'network': 'Visa',
    };

    final tJson = {
      'data': [tTransaction1Json, tTransaction2Json],
      'total_data': 25,
      'current_page': 2,
      'limit': 10,
    };

    group('fromJson', () {
      test('should return a valid TransactionsResponseModel from complete JSON', () {
        // act
        final result = TransactionsResponseModel.fromJson(tJson);

        // assert
        expect(result.transactions, isA<List<TransactionModel>>());
        expect(result.transactions.length, equals(2));
        expect(result.total, equals(25));
        expect(result.page, equals(2));
        expect(result.limit, equals(10));
        expect(result.hasMore, equals(true)); // 2 * 10 = 20 < 25
      });

      test('should correctly calculate hasMore when there are more transactions', () {
        // arrange
        final jsonWithMore = {
          'data': [tTransaction1Json],
          'total_data': 50,
          'current_page': 2,
          'limit': 10,
        };

        // act
        final result = TransactionsResponseModel.fromJson(jsonWithMore);

        // assert
        expect(result.hasMore, equals(true)); // 2 * 10 = 20 < 50
      });

      test('should correctly calculate hasMore when no more transactions', () {
        // arrange
        final jsonWithoutMore = {
          'data': [tTransaction1Json, tTransaction2Json],
          'total_data': 20,
          'current_page': 2,
          'limit': 10,
        };

        // act
        final result = TransactionsResponseModel.fromJson(jsonWithoutMore);

        // assert
        expect(result.hasMore, equals(false)); // 2 * 10 = 20 >= 20
      });

      test('should correctly calculate hasMore when loaded equals total', () {
        // arrange
        final jsonExact = {
          'data': [tTransaction1Json, tTransaction2Json],
          'total_data': 6,
          'current_page': 2,
          'limit': 3,
        };

        // act
        final result = TransactionsResponseModel.fromJson(jsonExact);

        // assert
        expect(result.hasMore, equals(false)); // 2 * 3 = 6 >= 6
      });

      test('should handle empty data list', () {
        // arrange
        final jsonEmpty = {
          'data': [],
          'total_data': 0,
          'current_page': 1,
          'limit': 10,
        };

        // act
        final result = TransactionsResponseModel.fromJson(jsonEmpty);

        // assert
        expect(result.transactions, isEmpty);
        expect(result.total, equals(0));
        expect(result.hasMore, equals(false));
      });

      test('should handle null values with defaults', () {
        // arrange
        final jsonWithNulls = {
          'data': [tTransaction1Json],
          'total_data': null,
          'current_page': null,
          'limit': null,
        };

        // act
        final result = TransactionsResponseModel.fromJson(jsonWithNulls);

        // assert
        expect(result.total, equals(0));
        expect(result.page, equals(1));
        expect(result.limit, equals(5));
        expect(result.hasMore, equals(false)); // 1 * 5 = 5 >= 0
      });

      test('should parse all transactions in data array', () {
        // act
        final result = TransactionsResponseModel.fromJson(tJson);

        // assert
        expect(result.transactions[0].transactionRef, equals('TXN001'));
        expect(result.transactions[0].amount, equals(5000.0));
        expect(result.transactions[1].transactionRef, equals('TXN002'));
        expect(result.transactions[1].amount, equals(3000.0));
      });
    });
  });
}
