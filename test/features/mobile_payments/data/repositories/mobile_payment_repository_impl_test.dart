import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/i_network_info.dart';
import 'package:todouapp/features/mobile_payments/data/datasources/i_mobile_payment_data_source.dart';
import 'package:todouapp/features/mobile_payments/data/models/mobile_payment_model.dart';
import 'package:todouapp/features/mobile_payments/data/repositories/mobile_payment_repository_impl.dart';

class MockMobilePaymentDataSource extends Mock
    implements IMobilePaymentDataSource {}

class MockNetworkInfo extends Mock implements INetworkInfo {}

void main() {
  late PaymentRepositoryImpl repository;
  late MockMobilePaymentDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockDataSource = MockMobilePaymentDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = PaymentRepositoryImpl(
      dataSource: mockDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(
      MobilePaymentInitRequest(
        amount: 0,
        currency: '',
        terminalId: 0,
        merchantId: 0,
        network: '',
        customerPhone: '',
        operatorOtp: '',
      ),
    );
  });

  group('initPayment', () {
    final tRequest = MobilePaymentInitRequest(
      amount: 5000.0,
      currency: 'XOF',
      terminalId: 123,
      merchantId: 456,
      network: 'orange_money',
      customerPhone: '221771234567',
      operatorOtp: '1234',
    );

    final tResponse = MobilePaymentInitResponse(
      paymentUrl: 'https://orange-money.com/pay/abc123',
      transactionId: 'TXN_001',
      reference: 'REF_001',
    );

    test('should return NetworkFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.initPayment(tRequest);

      // Assert
      expect(result, Left(NetworkFailure()));
      verifyNever(() => mockDataSource.initPayment(any()));
    });

    test('should return MobilePaymentInitResponse when device is online and call succeeds',
        () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.initPayment(any()))
          .thenAnswer((_) async => tResponse);

      // Act
      final result = await repository.initPayment(tRequest);

      // Assert
      expect(result, Right(tResponse));
      verify(() => mockDataSource.initPayment(tRequest)).called(1);
    });

    test('should return ServerFailure when ServerException is thrown', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.initPayment(any()))
          .thenThrow(ServerException(message: 'Server error'));

      // Act
      final result = await repository.initPayment(tRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message, 'Server error');
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should parse JSON error message from ServerException with 400 status',
        () async {
      // Arrange
      const errorMessage =
          '400: {"message":"Insufficient balance","code":"INSUFFICIENT_FUNDS"}';
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.initPayment(any()))
          .thenThrow(ServerException(message: errorMessage));

      // Act
      final result = await repository.initPayment(tRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message, 'Insufficient balance');
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should return original error message when JSON parsing fails',
        () async {
      // Arrange
      const errorMessage = '400: Invalid JSON {broken}';
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.initPayment(any()))
          .thenThrow(ServerException(message: errorMessage));

      // Act
      final result = await repository.initPayment(tRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message, errorMessage);
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should return default error message when unexpected exception occurs',
        () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.initPayment(any()))
          .thenThrow(Exception('Unknown error'));

      // Act
      final result = await repository.initPayment(tRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message,
              'Une erreur inattendue est survenue');
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should handle 400 error without message field in JSON', () async {
      // Arrange
      const errorMessage = '400: {"error":"Bad request","status":400}';
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.initPayment(any()))
          .thenThrow(ServerException(message: errorMessage));

      // Act
      final result = await repository.initPayment(tRequest);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message,
              "Une erreur s'est produite");
        },
        (_) => fail('Should return failure'),
      );
    });
  });

  group('verifyPayment', () {
    const tTransactionId = 'TXN_123456';
    final tResponse = MobilePaymentVerifyResponse(
      status: 'success',
      reference: 'REF_001',
      date: DateTime(2024, 1, 15, 10, 30),
    );

    test('should return NetworkFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.verifyPayment(tTransactionId);

      // Assert
      expect(result, Left(NetworkFailure()));
      verifyNever(() => mockDataSource.verifyPayment(any()));
    });

    test('should return MobilePaymentVerifyResponse when device is online and call succeeds',
        () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.verifyPayment(any()))
          .thenAnswer((_) async => tResponse);

      // Act
      final result = await repository.verifyPayment(tTransactionId);

      // Assert
      expect(result, Right(tResponse));
      verify(() => mockDataSource.verifyPayment(tTransactionId)).called(1);
    });

    test('should return ServerFailure when ServerException is thrown', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.verifyPayment(any()))
          .thenThrow(ServerException(message: 'Transaction not found'));

      // Act
      final result = await repository.verifyPayment(tTransactionId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message, 'Transaction not found');
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should return default error message when unexpected exception occurs',
        () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.verifyPayment(any()))
          .thenThrow(Exception('Unknown error'));

      // Act
      final result = await repository.verifyPayment(tTransactionId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message,
              'Une erreur inattendue est survenue');
        },
        (_) => fail('Should return failure'),
      );
    });
  });

  group('stripeVerifyPayment', () {
    const tTransactionId = 'STRIPE_TXN_789';
    final tResponse = MobilePaymentVerifyResponse(
      status: 'success',
      reference: 'STRIPE_REF_001',
      date: DateTime(2024, 1, 16, 14, 45),
    );

    test('should return NetworkFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.stripeVerifyPayment(tTransactionId);

      // Assert
      expect(result, Left(NetworkFailure()));
      verifyNever(() => mockDataSource.stripeVerifyPayment(any()));
    });

    test('should return MobilePaymentVerifyResponse when device is online and call succeeds',
        () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.stripeVerifyPayment(any()))
          .thenAnswer((_) async => tResponse);

      // Act
      final result = await repository.stripeVerifyPayment(tTransactionId);

      // Assert
      expect(result, Right(tResponse));
      verify(() => mockDataSource.stripeVerifyPayment(tTransactionId))
          .called(1);
    });

    test('should return ServerFailure when ServerException is thrown', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.stripeVerifyPayment(any()))
          .thenThrow(ServerException(message: 'Payment intent not found'));

      // Act
      final result = await repository.stripeVerifyPayment(tTransactionId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(
              (failure as ServerFailure).message, 'Payment intent not found');
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should return default error message when unexpected exception occurs',
        () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.stripeVerifyPayment(any()))
          .thenThrow(Exception('Network timeout'));

      // Act
      final result = await repository.stripeVerifyPayment(tTransactionId);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect((failure as ServerFailure).message,
              'Une erreur inattendue est survenue');
        },
        (_) => fail('Should return failure'),
      );
    });
  });
}
