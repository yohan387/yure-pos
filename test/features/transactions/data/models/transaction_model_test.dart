import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/features/transactions/data/models/transaction_model.dart';

void main() {
  group('TransactionModel', () {
    final tDateTime = DateTime.parse('2024-01-15T10:30:00.000Z');

    final tTransactionModel = TransactionModel(
      id: 1,
      merchantId: 100,
      terminalId: 200,
      amount: 5000.0,
      currency: 'XOF',
      transactionRef: 'TXN123456',
      date: tDateTime,
      paymentMethod: 'Mobile Money',
      status: 'success',
      customerPhone: '+221771234567',
      network: 'Orange Money',
    );

    final tJson = {
      'id': 1,
      'merchant_id': 100,
      'terminal_id': 200,
      'amount': 5000,
      'currency': 'XOF',
      'transaction_ref': 'TXN123456',
      'created_at': '2024-01-15T10:30:00.000Z',
      'payment_method': 'Mobile Money',
      'status': 'success',
      'customer_phone': '+221771234567',
      'network': 'Orange Money',
    };

    group('fromJson', () {
      test('should return a valid TransactionModel from complete JSON', () {
        // act
        final result = TransactionModel.fromJson(tJson);

        // assert
        expect(result.id, equals(1));
        expect(result.merchantId, equals(100));
        expect(result.terminalId, equals(200));
        expect(result.amount, equals(5000.0));
        expect(result.currency, equals('XOF'));
        expect(result.transactionRef, equals('TXN123456'));
        expect(result.date, equals(tDateTime));
        expect(result.paymentMethod, equals('Mobile Money'));
        expect(result.status, equals('success'));
        expect(result.customerPhone, equals('+221771234567'));
        expect(result.network, equals('Orange Money'));
      });

      test('should handle null id with 0 default', () {
        // arrange
        final jsonWithNullId = {...tJson, 'id': null};

        // act
        final result = TransactionModel.fromJson(jsonWithNullId);

        // assert
        expect(result.id, equals(0));
      });

      test('should handle null currency with empty string default', () {
        // arrange
        final jsonWithNullCurrency = {...tJson, 'currency': null};

        // act
        final result = TransactionModel.fromJson(jsonWithNullCurrency);

        // assert
        expect(result.currency, equals(''));
      });

      test('should handle null created_at with DateTime.now()', () {
        // arrange
        final jsonWithNullDate = {...tJson, 'created_at': null};

        // act
        final result = TransactionModel.fromJson(jsonWithNullDate);

        // assert
        expect(result.date, isNotNull);
        expect(result.date.isBefore(DateTime.now().add(Duration(seconds: 1))), isTrue);
      });

      test('should handle null status with empty string default', () {
        // arrange
        final jsonWithNullStatus = {...tJson, 'status': null};

        // act
        final result = TransactionModel.fromJson(jsonWithNullStatus);

        // assert
        expect(result.status, equals(''));
      });

      test('should handle null merchant_id with 0 default', () {
        // arrange
        final jsonWithNullMerchantId = {...tJson, 'merchant_id': null};

        // act
        final result = TransactionModel.fromJson(jsonWithNullMerchantId);

        // assert
        expect(result.merchantId, equals(0));
      });

      test('should handle null terminal_id with 0 default', () {
        // arrange
        final jsonWithNullTerminalId = {...tJson, 'terminal_id': null};

        // act
        final result = TransactionModel.fromJson(jsonWithNullTerminalId);

        // assert
        expect(result.terminalId, equals(0));
      });

      test('should handle null transaction_ref with empty string default', () {
        // arrange
        final jsonWithNullRef = {...tJson, 'transaction_ref': null};

        // act
        final result = TransactionModel.fromJson(jsonWithNullRef);

        // assert
        expect(result.transactionRef, equals(''));
      });

      test('should handle null payment_method with "Mobile Money" default', () {
        // arrange
        final jsonWithNullPaymentMethod = {...tJson, 'payment_method': null};

        // act
        final result = TransactionModel.fromJson(jsonWithNullPaymentMethod);

        // assert
        expect(result.paymentMethod, equals('Mobile Money'));
      });

      test('should handle null customer_phone with empty string default', () {
        // arrange
        final jsonWithNullPhone = {...tJson, 'customer_phone': null};

        // act
        final result = TransactionModel.fromJson(jsonWithNullPhone);

        // assert
        expect(result.customerPhone, equals(''));
      });

      test('should handle null network with empty string default', () {
        // arrange
        final jsonWithNullNetwork = {...tJson, 'network': null};

        // act
        final result = TransactionModel.fromJson(jsonWithNullNetwork);

        // assert
        expect(result.network, equals(''));
      });

      test('should convert int amount to double', () {
        // arrange
        final jsonWithIntAmount = {...tJson, 'amount': 5000};

        // act
        final result = TransactionModel.fromJson(jsonWithIntAmount);

        // assert
        expect(result.amount, isA<double>());
        expect(result.amount, equals(5000.0));
      });

      test('should convert double amount correctly', () {
        // arrange
        final jsonWithDoubleAmount = {...tJson, 'amount': 5000.50};

        // act
        final result = TransactionModel.fromJson(jsonWithDoubleAmount);

        // assert
        expect(result.amount, equals(5000.50));
      });

      test('should parse ISO 8601 date string correctly', () {
        // arrange
        final dateString = '2024-12-25T15:45:30.123Z';
        final jsonWithDate = {...tJson, 'created_at': dateString};
        final expectedDate = DateTime.parse(dateString);

        // act
        final result = TransactionModel.fromJson(jsonWithDate);

        // assert
        expect(result.date, equals(expectedDate));
      });

      test('should handle all null fields with proper defaults', () {
        // arrange
        final jsonAllNulls = {
          'id': null,
          'merchant_id': null,
          'terminal_id': null,
          'amount': 1000,
          'currency': null,
          'transaction_ref': null,
          'created_at': null,
          'payment_method': null,
          'status': null,
          'customer_phone': null,
          'network': null,
        };

        // act
        final result = TransactionModel.fromJson(jsonAllNulls);

        // assert
        expect(result.id, equals(0));
        expect(result.merchantId, equals(0));
        expect(result.terminalId, equals(0));
        expect(result.amount, equals(1000.0));
        expect(result.currency, equals(''));
        expect(result.transactionRef, equals(''));
        expect(result.paymentMethod, equals('Mobile Money'));
        expect(result.status, equals(''));
        expect(result.customerPhone, equals(''));
        expect(result.network, equals(''));
        expect(result.date, isNotNull);
      });
    });
  });
}
