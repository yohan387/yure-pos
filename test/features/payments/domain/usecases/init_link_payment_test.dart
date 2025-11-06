import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/payments/data/models/stripe_payment_intent_response.dart';
import 'package:todouapp/features/payments/domain/repositories/i_stripe_payment_repository.dart';
import 'package:todouapp/features/payments/domain/usescases/init_link_payment.dart';

// Mock
class MockStripePaymentRepository extends Mock
    implements IStripePaymentRepository {}

void main() {
  late InitLinkPayment usecase;
  late MockStripePaymentRepository mockRepository;

  setUp(() {
    mockRepository = MockStripePaymentRepository();
    usecase = InitLinkPayment(mockRepository);
  });

  group('InitLinkPayment', () {
    const tAmount = 50000;
    final tResponse = StripeLinkToPayResponse(
      paymentLink: 'https://stripe.com/payment/link123',
      transactionRef: 'txn_abc123',
    );

    test('should call repository.createLinkPayment with correct amount',
        () async {
      // Arrange
      when(() => mockRepository.createLinkPayment(tAmount))
          .thenAnswer((_) async => Right(tResponse));

      // Act
      await usecase.call(tAmount);

      // Assert
      verify(() => mockRepository.createLinkPayment(tAmount)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return StripeLinkToPayResponse when repository call succeeds',
        () async {
      // Arrange
      when(() => mockRepository.createLinkPayment(tAmount))
          .thenAnswer((_) async => Right(tResponse));

      // Act
      final result = await usecase.call(tAmount);

      // Assert
      expect(result, equals(Right(tResponse)));
      expect(
        result.fold(
          (failure) => null,
          (response) => response,
        ),
        equals(tResponse),
      );
    });

    test('should return NetworkFailure when repository returns NetworkFailure',
        () async {
      // Arrange
      final tFailure = NetworkFailure();
      when(() => mockRepository.createLinkPayment(tAmount))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await usecase.call(tAmount);

      // Assert
      expect(result, equals(Left(tFailure)));
    });

    test('should return ServerFailure when repository returns ServerFailure',
        () async {
      // Arrange
      const errorMessage = 'Server error occurred';
      final tFailure = ServerFailure(message: errorMessage);
      when(() => mockRepository.createLinkPayment(tAmount))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await usecase.call(tAmount);

      // Assert
      expect(result, equals(Left(tFailure)));
      expect(
        result.fold(
          (failure) => (failure as ServerFailure).message,
          (response) => null,
        ),
        errorMessage,
      );
    });

    test('should handle zero amount', () async {
      // Arrange
      const zeroAmount = 0;
      final zeroResponse = StripeLinkToPayResponse(
        paymentLink: 'https://stripe.com/zero',
        transactionRef: 'txn_zero',
      );
      when(() => mockRepository.createLinkPayment(zeroAmount))
          .thenAnswer((_) async => Right(zeroResponse));

      // Act
      final result = await usecase.call(zeroAmount);

      // Assert
      expect(result, equals(Right(zeroResponse)));
      verify(() => mockRepository.createLinkPayment(zeroAmount)).called(1);
    });

    test('should handle large amounts', () async {
      // Arrange
      const largeAmount = 999999999;
      final largeResponse = StripeLinkToPayResponse(
        paymentLink: 'https://stripe.com/large',
        transactionRef: 'txn_large',
      );
      when(() => mockRepository.createLinkPayment(largeAmount))
          .thenAnswer((_) async => Right(largeResponse));

      // Act
      final result = await usecase.call(largeAmount);

      // Assert
      expect(result, equals(Right(largeResponse)));
      verify(() => mockRepository.createLinkPayment(largeAmount)).called(1);
    });

    test('should propagate response with empty payment link', () async {
      // Arrange
      final emptyLinkResponse = StripeLinkToPayResponse(
        paymentLink: '',
        transactionRef: 'txn_empty',
      );
      when(() => mockRepository.createLinkPayment(tAmount))
          .thenAnswer((_) async => Right(emptyLinkResponse));

      // Act
      final result = await usecase.call(tAmount);

      // Assert
      expect(result, equals(Right(emptyLinkResponse)));
      expect(
        result.fold(
          (failure) => null,
          (response) => response.paymentLink,
        ),
        '',
      );
    });

    test('should return correct Either type', () async {
      // Arrange
      when(() => mockRepository.createLinkPayment(tAmount))
          .thenAnswer((_) async => Right(tResponse));

      // Act
      final result = await usecase.call(tAmount);

      // Assert
      expect(result, isA<Either<Failure, StripeLinkToPayResponse>>());
    });
  });

  group('InitLinkPayment - constructor', () {
    test('should create instance with repository', () {
      // Act
      final usecase = InitLinkPayment(mockRepository);

      // Assert
      expect(usecase, isA<InitLinkPayment>());
    });
  });
}
