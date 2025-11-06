import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/mobile_payments/data/models/mobile_payment_model.dart';
import 'package:todouapp/features/mobile_payments/domain/repositories/i_mobile_payment_repository.dart';
import 'package:todouapp/features/mobile_payments/domain/usecases/verify_payment.dart';

class MockMobilePaymentRepository extends Mock
    implements IMobilePaymentRepository {}

void main() {
  late VerifyPayment usecase;
  late MockMobilePaymentRepository mockRepository;

  setUp(() {
    mockRepository = MockMobilePaymentRepository();
    usecase = VerifyPayment(mockRepository);
  });

  group('VerifyPayment', () {
    const tTransactionId = 'TXN_123456';
    final tResponse = MobilePaymentVerifyResponse(
      status: 'success',
      reference: 'REF_001',
      date: DateTime(2024, 1, 15, 10, 30),
    );

    test('should call repository verifyPayment with correct transaction ID',
        () async {
      // Arrange
      when(() => mockRepository.verifyPayment(any()))
          .thenAnswer((_) async => Right(tResponse));

      // Act
      await usecase.call(tTransactionId);

      // Assert
      verify(() => mockRepository.verifyPayment(tTransactionId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return MobilePaymentVerifyResponse with success status',
        () async {
      // Arrange
      when(() => mockRepository.verifyPayment(any()))
          .thenAnswer((_) async => Right(tResponse));

      // Act
      final result = await usecase.call(tTransactionId);

      // Assert
      expect(result, Right(tResponse));
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (response) {
          expect(response.status, 'success');
          expect(response.reference, 'REF_001');
          expect(response.date, DateTime(2024, 1, 15, 10, 30));
        },
      );
    });

    test('should return MobilePaymentVerifyResponse with pending status',
        () async {
      // Arrange
      final pendingResponse = MobilePaymentVerifyResponse(
        status: 'pending',
        reference: 'REF_002',
        date: DateTime(2024, 1, 15, 10, 35),
      );
      when(() => mockRepository.verifyPayment(any()))
          .thenAnswer((_) async => Right(pendingResponse));

      // Act
      final result = await usecase.call(tTransactionId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (response) {
          expect(response.status, 'pending');
          expect(response.reference, 'REF_002');
        },
      );
    });

    test('should return MobilePaymentVerifyResponse with failed status',
        () async {
      // Arrange
      final failedResponse = MobilePaymentVerifyResponse(
        status: 'failed',
        reference: 'REF_003',
        date: DateTime(2024, 1, 15, 10, 40),
      );
      when(() => mockRepository.verifyPayment(any()))
          .thenAnswer((_) async => Right(failedResponse));

      // Act
      final result = await usecase.call(tTransactionId);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should return success'),
        (response) {
          expect(response.status, 'failed');
        },
      );
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // Arrange
      when(() => mockRepository.verifyPayment(any()))
          .thenAnswer((_) async => const Left(NetworkFailure()));

      // Act
      final result = await usecase.call(tTransactionId);

      // Assert
      expect(result, const Left(NetworkFailure()));
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ServerFailure when transaction not found', () async {
      // Arrange
      const tFailure = ServerFailure(message: 'Transaction not found');
      when(() => mockRepository.verifyPayment(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase.call(tTransactionId);

      // Assert
      expect(result, const Left(tFailure));
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Transaction not found');
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should handle different transaction ID formats', () async {
      // Arrange
      const differentTransactionId = 'WAVE_TXN_789_XYZ';
      when(() => mockRepository.verifyPayment(any()))
          .thenAnswer((_) async => Right(tResponse));

      // Act
      final result = await usecase.call(differentTransactionId);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.verifyPayment(differentTransactionId))
          .called(1);
    });
  });
}
