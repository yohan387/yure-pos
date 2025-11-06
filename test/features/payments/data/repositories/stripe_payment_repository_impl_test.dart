import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/i_network_info.dart';
import 'package:todouapp/features/payments/data/datasources/i_stripe_payment_data_source.dart';
import 'package:todouapp/features/payments/data/models/stripe_payment_intent_response.dart';
import 'package:todouapp/features/payments/data/repositories/stripe_payment_repository_impl.dart';

// Mocks
class MockStripePaymentDataSource extends Mock
    implements IStripePaymentDataSource {}

class MockNetworkInfo extends Mock implements INetworkInfo {}

void main() {
  late StripePaymentRepositoryImpl repository;
  late MockStripePaymentDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockDataSource = MockStripePaymentDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = StripePaymentRepositoryImpl(
      dataSource: mockDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('StripePaymentRepositoryImpl', () {
    group('createPaymentIntent', () {
      const tAmount = 50000;
      final tResponse = StripePaymentIntentResponse(
        clientSecret: 'pi_test_secret_12345',
      );

      test('should check network connectivity before making request', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createPaymentIntent(any()))
            .thenAnswer((_) async => tResponse);

        // Act
        await repository.createPaymentIntent(tAmount);

        // Assert
        verify(() => mockNetworkInfo.isConnected).called(1);
      });

      test(
          'should return NetworkFailure when device has no internet connection',
          () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.createPaymentIntent(tAmount);

        // Assert
        expect(result, equals(Left(NetworkFailure())));
        verifyNever(() => mockDataSource.createPaymentIntent(any()));
      });

      test('should return StripePaymentIntentResponse when call is successful',
          () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createPaymentIntent(tAmount))
            .thenAnswer((_) async => tResponse);

        // Act
        final result = await repository.createPaymentIntent(tAmount);

        // Assert
        expect(result, equals(Right(tResponse)));
        verify(() => mockDataSource.createPaymentIntent(tAmount)).called(1);
      });

      test('should call dataSource with correct amount', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createPaymentIntent(tAmount))
            .thenAnswer((_) async => tResponse);

        // Act
        await repository.createPaymentIntent(tAmount);

        // Assert
        verify(() => mockDataSource.createPaymentIntent(tAmount)).called(1);
      });

      test('should return ServerFailure when dataSource throws ServerException',
          () async {
        // Arrange
        const errorMessage = 'Payment intent creation failed';
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createPaymentIntent(tAmount))
            .thenThrow(ServerException(message: errorMessage));

        // Act
        final result = await repository.createPaymentIntent(tAmount);

        // Assert
        expect(
          result,
          equals(Left(ServerFailure(message: errorMessage))),
        );
      });

      test(
          'should return ServerFailure with generic message when dataSource throws unexpected error',
          () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createPaymentIntent(tAmount))
            .thenThrow(Exception('Unexpected error'));

        // Act
        final result = await repository.createPaymentIntent(tAmount);

        // Assert
        expect(
          result,
          equals(
              Left(ServerFailure(message: 'Une erreur inattendue est survenue'))),
        );
      });

      test('should handle zero amount', () async {
        // Arrange
        const zeroAmount = 0;
        final zeroResponse = StripePaymentIntentResponse(
          clientSecret: 'pi_test_zero',
        );
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createPaymentIntent(zeroAmount))
            .thenAnswer((_) async => zeroResponse);

        // Act
        final result = await repository.createPaymentIntent(zeroAmount);

        // Assert
        expect(result, equals(Right(zeroResponse)));
        verify(() => mockDataSource.createPaymentIntent(zeroAmount)).called(1);
      });

      test('should handle large amounts', () async {
        // Arrange
        const largeAmount = 999999999;
        final largeResponse = StripePaymentIntentResponse(
          clientSecret: 'pi_test_large',
        );
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createPaymentIntent(largeAmount))
            .thenAnswer((_) async => largeResponse);

        // Act
        final result = await repository.createPaymentIntent(largeAmount);

        // Assert
        expect(result, equals(Right(largeResponse)));
      });
    });

    group('createLinkPayment', () {
      const tAmount = 100000;
      final tResponse = StripeLinkToPayResponse(
        paymentLink: 'https://stripe.com/payment/link123',
        transactionRef: 'txn_abc123',
      );

      test('should check network connectivity before making request', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createLinkPayment(any()))
            .thenAnswer((_) async => tResponse);

        // Act
        await repository.createLinkPayment(tAmount);

        // Assert
        verify(() => mockNetworkInfo.isConnected).called(1);
      });

      test(
          'should return NetworkFailure when device has no internet connection',
          () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.createLinkPayment(tAmount);

        // Assert
        expect(result, equals(Left(NetworkFailure())));
        verifyNever(() => mockDataSource.createLinkPayment(any()));
      });

      test('should return StripeLinkToPayResponse when call is successful',
          () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createLinkPayment(tAmount))
            .thenAnswer((_) async => tResponse);

        // Act
        final result = await repository.createLinkPayment(tAmount);

        // Assert
        expect(result, equals(Right(tResponse)));
        verify(() => mockDataSource.createLinkPayment(tAmount)).called(1);
      });

      test('should call dataSource with correct amount', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createLinkPayment(tAmount))
            .thenAnswer((_) async => tResponse);

        // Act
        await repository.createLinkPayment(tAmount);

        // Assert
        verify(() => mockDataSource.createLinkPayment(tAmount)).called(1);
      });

      test('should return ServerFailure when dataSource throws ServerException',
          () async {
        // Arrange
        const errorMessage = 'Link payment creation failed';
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createLinkPayment(tAmount))
            .thenThrow(ServerException(message: errorMessage));

        // Act
        final result = await repository.createLinkPayment(tAmount);

        // Assert
        expect(
          result,
          equals(Left(ServerFailure(message: errorMessage))),
        );
      });

      test(
          'should return ServerFailure with generic message when dataSource throws unexpected error',
          () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createLinkPayment(tAmount))
            .thenThrow(Exception('Network timeout'));

        // Act
        final result = await repository.createLinkPayment(tAmount);

        // Assert
        expect(
          result,
          equals(
              Left(ServerFailure(message: 'Une erreur inattendue est survenue'))),
        );
      });

      test('should handle zero amount', () async {
        // Arrange
        const zeroAmount = 0;
        final zeroResponse = StripeLinkToPayResponse(
          paymentLink: 'https://stripe.com/zero',
          transactionRef: 'txn_zero',
        );
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createLinkPayment(zeroAmount))
            .thenAnswer((_) async => zeroResponse);

        // Act
        final result = await repository.createLinkPayment(zeroAmount);

        // Assert
        expect(result, equals(Right(zeroResponse)));
        verify(() => mockDataSource.createLinkPayment(zeroAmount)).called(1);
      });

      test('should handle large amounts', () async {
        // Arrange
        const largeAmount = 999999999;
        final largeResponse = StripeLinkToPayResponse(
          paymentLink: 'https://stripe.com/large',
          transactionRef: 'txn_large',
        );
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createLinkPayment(largeAmount))
            .thenAnswer((_) async => largeResponse);

        // Act
        final result = await repository.createLinkPayment(largeAmount);

        // Assert
        expect(result, equals(Right(largeResponse)));
      });

      test('should handle empty payment link in response', () async {
        // Arrange
        final emptyLinkResponse = StripeLinkToPayResponse(
          paymentLink: '',
          transactionRef: 'txn_empty',
        );
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.createLinkPayment(tAmount))
            .thenAnswer((_) async => emptyLinkResponse);

        // Act
        final result = await repository.createLinkPayment(tAmount);

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
    });

    group('constructor', () {
      test('should create instance with required dependencies', () {
        // Act
        final repo = StripePaymentRepositoryImpl(
          dataSource: mockDataSource,
          networkInfo: mockNetworkInfo,
        );

        // Assert
        expect(repo, isA<StripePaymentRepositoryImpl>());
      });
    });
  });
}
