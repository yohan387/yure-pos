import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/mobile_payments/data/models/mobile_payment_model.dart';
import 'package:todouapp/features/mobile_payments/domain/repositories/i_mobile_payment_repository.dart';
import 'package:todouapp/features/mobile_payments/domain/usecases/init_payment.dart';

class MockMobilePaymentRepository extends Mock
    implements IMobilePaymentRepository {}

void main() {
  late InitPayment usecase;
  late MockMobilePaymentRepository mockRepository;

  setUp(() {
    mockRepository = MockMobilePaymentRepository();
    usecase = InitPayment(mockRepository);
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

  group('InitPayment', () {
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

    const tIdempotencyKey = 'test-key-123';

    test('should call repository initPayment with correct parameters', () async {
      // Arrange
      when(() => mockRepository.initPayment(
            request: any(named: 'request'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).thenAnswer((_) async => Right(tResponse));

      // Act
      await usecase.call(request: tRequest, idempotencyKey: tIdempotencyKey);

      // Assert
      verify(() => mockRepository.initPayment(
            request: tRequest,
            idempotencyKey: tIdempotencyKey,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return MobilePaymentInitResponse when repository call succeeds',
        () async {
      // Arrange
      when(() => mockRepository.initPayment(
            request: any(named: 'request'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).thenAnswer((_) async => Right(tResponse));

      // Act
      final result = await usecase.call(request: tRequest, idempotencyKey: tIdempotencyKey);

      // Assert
      expect(result, Right(tResponse));
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (response) {
          expect(response.paymentUrl, 'https://orange-money.com/pay/abc123');
          expect(response.transactionId, 'TXN_001');
          expect(response.reference, 'REF_001');
        },
      );
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // Arrange
      when(() => mockRepository.initPayment(
            request: any(named: 'request'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).thenAnswer((_) async => const Left(NetworkFailure()));

      // Act
      final result = await usecase.call(request: tRequest, idempotencyKey: tIdempotencyKey);

      // Assert
      expect(result, const Left(NetworkFailure()));
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ServerFailure when server returns error', () async {
      // Arrange
      const tFailure = ServerFailure(message: 'Insufficient balance');
      when(() => mockRepository.initPayment(
            request: any(named: 'request'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase.call(request: tRequest, idempotencyKey: tIdempotencyKey);

      // Assert
      expect(result, const Left(tFailure));
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Insufficient balance');
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should work with Orange Money network', () async {
      // Arrange
      final orangeRequest = MobilePaymentInitRequest(
        amount: 10000.0,
        currency: 'XOF',
        terminalId: 999,
        merchantId: 888,
        network: 'orange_money',
        customerPhone: '221771111111',
        operatorOtp: '5678',
      );
      when(() => mockRepository.initPayment(
            request: any(named: 'request'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).thenAnswer((_) async => Right(tResponse));

      // Act
      final result = await usecase.call(request: orangeRequest, idempotencyKey: tIdempotencyKey);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.initPayment(
            request: orangeRequest,
            idempotencyKey: tIdempotencyKey,
          )).called(1);
    });

    test('should work with Wave network', () async {
      // Arrange
      final waveRequest = MobilePaymentInitRequest(
        amount: 7500.0,
        currency: 'XOF',
        terminalId: 111,
        merchantId: 222,
        network: 'wave',
        customerPhone: '221779876543',
        operatorOtp: '0000',
      );
      final waveResponse = MobilePaymentInitResponse(
        paymentUrl: 'https://wave.com/pay/xyz789',
        transactionId: 'WAVE_TXN_001',
        reference: 'WAVE_REF_001',
      );
      when(() => mockRepository.initPayment(
            request: any(named: 'request'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).thenAnswer((_) async => Right(waveResponse));

      // Act
      final result = await usecase.call(request: waveRequest, idempotencyKey: tIdempotencyKey);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (response) {
          expect(response.paymentUrl, 'https://wave.com/pay/xyz789');
          expect(response.transactionId, 'WAVE_TXN_001');
        },
      );
    });

    test('should handle different amounts correctly', () async {
      // Arrange
      final smallAmountRequest = MobilePaymentInitRequest(
        amount: 100.0,
        currency: 'XOF',
        terminalId: 123,
        merchantId: 456,
        network: 'orange_money',
        customerPhone: '221771234567',
        operatorOtp: '1234',
      );
      when(() => mockRepository.initPayment(
            request: any(named: 'request'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).thenAnswer((_) async => Right(tResponse));

      // Act
      final result = await usecase.call(request: smallAmountRequest, idempotencyKey: tIdempotencyKey);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.initPayment(
            request: smallAmountRequest,
            idempotencyKey: tIdempotencyKey,
          )).called(1);
    });

    test('should handle ValidationFailure for invalid input', () async {
      // Arrange
      const tFailure = ValidationFailure(message: 'Invalid phone number');
      when(() => mockRepository.initPayment(
            request: any(named: 'request'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase.call(request: tRequest, idempotencyKey: tIdempotencyKey);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, 'Invalid phone number');
        },
        (_) => fail('Should return failure'),
      );
    });
  });
}
