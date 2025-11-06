import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/mobile_payments/data/models/mobile_payment_model.dart';
import 'package:todouapp/features/mobile_payments/domain/repositories/i_mobile_payment_repository.dart';
import 'package:todouapp/features/mobile_payments/domain/usecases/stripe_verify_payment.dart';

class MockMobilePaymentRepository extends Mock
    implements IMobilePaymentRepository {}

void main() {
  late StripeVerifyPayment usecase;
  late MockMobilePaymentRepository mockRepository;

  setUp(() {
    mockRepository = MockMobilePaymentRepository();
    usecase = StripeVerifyPayment(mockRepository);
  });

  group('StripeVerifyPayment', () {
    const tTransactionId = 'STRIPE_TXN_123456';
    final tResponse = MobilePaymentVerifyResponse(
      status: 'success',
      reference: 'STRIPE_REF_001',
      date: DateTime(2024, 1, 15, 10, 30),
    );

    test('should call repository stripeVerifyPayment with correct transaction ID',
        () async {
      // Arrange
      when(() => mockRepository.stripeVerifyPayment(any()))
          .thenAnswer((_) async => Right(tResponse));

      // Act
      await usecase.call(tTransactionId);

      // Assert
      verify(() => mockRepository.stripeVerifyPayment(tTransactionId))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return MobilePaymentVerifyResponse when verification succeeds',
        () async {
      // Arrange
      when(() => mockRepository.stripeVerifyPayment(any()))
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
          expect(response.reference, 'STRIPE_REF_001');
          expect(response.date, DateTime(2024, 1, 15, 10, 30));
        },
      );
    });

    test('should return NetworkFailure when network is unavailable', () async {
      // Arrange
      when(() => mockRepository.stripeVerifyPayment(any()))
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

    test('should return ServerFailure when payment intent not found', () async {
      // Arrange
      const tFailure = ServerFailure(message: 'Payment intent not found');
      when(() => mockRepository.stripeVerifyPayment(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // Act
      final result = await usecase.call(tTransactionId);

      // Assert
      expect(result, const Left(tFailure));
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Payment intent not found');
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should handle Stripe-specific transaction ID format', () async {
      // Arrange
      const stripeTransactionId = 'pi_1234567890ABCDEF';
      when(() => mockRepository.stripeVerifyPayment(any()))
          .thenAnswer((_) async => Right(tResponse));

      // Act
      final result = await usecase.call(stripeTransactionId);

      // Assert
      expect(result.isRight(), true);
      verify(() => mockRepository.stripeVerifyPayment(stripeTransactionId))
          .called(1);
    });
  });
}
