import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/features/mobile_payments/data/models/mobile_payment_model.dart';

void main() {
  group('MobilePaymentInitRequest', () {
    test('should create a valid MobilePaymentInitRequest for Orange Money', () {
      // Arrange
      final request = MobilePaymentInitRequest(
        amount: 5000.0,
        currency: 'XOF',
        terminalId: 123,
        merchantId: 456,
        network: 'orange_money',
        customerPhone: '221771234567',
        operatorOtp: '1234',
      );

      // Assert
      expect(request.amount, 5000.0);
      expect(request.currency, 'XOF');
      expect(request.terminalId, 123);
      expect(request.merchantId, 456);
      expect(request.network, 'orange_money');
      expect(request.customerPhone, '221771234567');
      expect(request.operatorOtp, '1234');
    });

    test('should create a valid MobilePaymentInitRequest for Wave', () {
      // Arrange
      final request = MobilePaymentInitRequest(
        amount: 10000.0,
        currency: 'XOF',
        terminalId: 789,
        merchantId: 101,
        network: 'wave',
        customerPhone: '221779876543',
        operatorOtp: '5678',
      );

      // Assert
      expect(request.amount, 10000.0);
      expect(request.network, 'wave');
      expect(request.customerPhone, '221779876543');
      expect(request.operatorOtp, '5678');
    });

    test('should correctly serialize to JSON with proper field names', () {
      // Arrange
      final request = MobilePaymentInitRequest(
        amount: 5000.0,
        currency: 'XOF',
        terminalId: 123,
        merchantId: 456,
        network: 'orange_money',
        customerPhone: '221771234567',
        operatorOtp: '1234',
      );

      // Act
      final json = request.toJson();

      // Assert
      expect(json, {
        'amount': 5000.0,
        'currency': 'XOF',
        'terminal_id': 123,
        'merchant_id': 456,
        'network': 'orange_money',
        'customer_phone': '221771234567',
        'operator_otp': '1234',
      });
    });

    test('should correctly serialize with snake_case field names', () {
      // Arrange
      final request = MobilePaymentInitRequest(
        amount: 2500.0,
        currency: 'XOF',
        terminalId: 999,
        merchantId: 888,
        network: 'wave',
        customerPhone: '221771111111',
        operatorOtp: '0000',
      );

      // Act
      final json = request.toJson();

      // Assert
      expect(json.containsKey('terminal_id'), true);
      expect(json.containsKey('merchant_id'), true);
      expect(json.containsKey('customer_phone'), true);
      expect(json.containsKey('operator_otp'), true);
      expect(json['terminal_id'], 999);
      expect(json['merchant_id'], 888);
    });
  });

  group('MobilePaymentInitResponse', () {
    test('should deserialize from JSON with payment_url_operator', () {
      // Arrange
      final json = {
        'payment_url_operator': 'https://wave.com/pay/abc123',
        'transaction_ref': 'TXN_123456',
      };

      // Act
      final response = MobilePaymentInitResponse.fromJson(json);

      // Assert
      expect(response.paymentUrl, 'https://wave.com/pay/abc123');
      expect(response.transactionId, 'TXN_123456');
      expect(response.reference, 'TXN_123456');
    });

    test('should handle missing payment_url_operator with empty string', () {
      // Arrange
      final json = {
        'transaction_ref': 'TXN_789',
      };

      // Act
      final response = MobilePaymentInitResponse.fromJson(json);

      // Assert
      expect(response.paymentUrl, '');
      expect(response.transactionId, 'TXN_789');
      expect(response.reference, 'TXN_789');
    });

    test('should correctly map transaction_ref to both transactionId and reference', () {
      // Arrange
      final json = {
        'payment_url_operator': 'https://orange-money.com/pay/xyz789',
        'transaction_ref': 'REF_ORANGE_001',
      };

      // Act
      final response = MobilePaymentInitResponse.fromJson(json);

      // Assert
      expect(response.transactionId, 'REF_ORANGE_001');
      expect(response.reference, 'REF_ORANGE_001');
      expect(response.transactionId, response.reference);
    });

    test('should create response with constructor parameters', () {
      // Act
      final response = MobilePaymentInitResponse(
        paymentUrl: 'https://example.com/qr',
        transactionId: 'TXN_999',
        reference: 'REF_999',
      );

      // Assert
      expect(response.paymentUrl, 'https://example.com/qr');
      expect(response.transactionId, 'TXN_999');
      expect(response.reference, 'REF_999');
    });
  });

  group('MobilePaymentVerifyResponse', () {
    test('should deserialize from JSON with success status', () {
      // Arrange
      final json = {
        'status': 'success',
        'transaction_ref': 'TXN_SUCCESS_001',
        'created_at': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final response = MobilePaymentVerifyResponse.fromJson(json);

      // Assert
      expect(response.status, 'success');
      expect(response.reference, 'TXN_SUCCESS_001');
      expect(response.date, DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    test('should deserialize from JSON with pending status', () {
      // Arrange
      final json = {
        'status': 'pending',
        'transaction_ref': 'TXN_PENDING_002',
        'created_at': '2024-01-16T14:45:30.000Z',
      };

      // Act
      final response = MobilePaymentVerifyResponse.fromJson(json);

      // Assert
      expect(response.status, 'pending');
      expect(response.reference, 'TXN_PENDING_002');
    });

    test('should deserialize from JSON with failed status', () {
      // Arrange
      final json = {
        'status': 'failed',
        'transaction_ref': 'TXN_FAILED_003',
        'created_at': '2024-01-17T09:15:00.000Z',
      };

      // Act
      final response = MobilePaymentVerifyResponse.fromJson(json);

      // Assert
      expect(response.status, 'failed');
      expect(response.reference, 'TXN_FAILED_003');
    });

    test('should correctly parse ISO 8601 date format', () {
      // Arrange
      final json = {
        'status': 'success',
        'transaction_ref': 'TXN_DATE_TEST',
        'created_at': '2024-03-20T18:30:45.123Z',
      };

      // Act
      final response = MobilePaymentVerifyResponse.fromJson(json);

      // Assert
      expect(response.date.year, 2024);
      expect(response.date.month, 3);
      expect(response.date.day, 20);
      expect(response.date.hour, 18);
      expect(response.date.minute, 30);
      expect(response.date.second, 45);
    });

    test('should create response with constructor parameters', () {
      // Arrange
      final testDate = DateTime(2024, 1, 1, 12, 0, 0);

      // Act
      final response = MobilePaymentVerifyResponse(
        status: 'success',
        reference: 'MANUAL_REF',
        date: testDate,
      );

      // Assert
      expect(response.status, 'success');
      expect(response.reference, 'MANUAL_REF');
      expect(response.date, testDate);
    });
  });
}
