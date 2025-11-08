import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/utils/idempotency_key_manager.dart';
import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/features/payments/data/models/stripe_payment_intent_response.dart';
import 'package:todouapp/features/payments/domain/repositories/i_stripe_payment_repository.dart';
import 'package:todouapp/features/payments/domain/usescases/init_link_payment.dart';
import 'package:todouapp/features/payments/presentation/bloc/stripe_payment_bloc.dart';

class MockStripePaymentRepository extends Mock
    implements IStripePaymentRepository {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockInitLinkPayment extends Mock implements InitLinkPayment {}

class MockIdempotencyKeyManager extends Mock implements IdempotencyKeyManager {}

void main() {
  late StripePaymentBloc bloc;
  late MockStripePaymentRepository mockRepository;
  late MockSecureStorageService mockSecureStorage;
  late MockInitLinkPayment mockInitLinkPayment;
  late MockIdempotencyKeyManager mockIdempotencyKeyManager;

  setUp(() {
    mockRepository = MockStripePaymentRepository();
    mockSecureStorage = MockSecureStorageService();
    mockInitLinkPayment = MockInitLinkPayment();
    mockIdempotencyKeyManager = MockIdempotencyKeyManager();

    bloc = StripePaymentBloc(
      repository: mockRepository,
      secureStorage: mockSecureStorage,
      initLinkPayment: mockInitLinkPayment,
      idempotencyKeyManager: mockIdempotencyKeyManager,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('StripePaymentBloc - Idempotency Tests', () {
    const testIdempotencyKey = 'test-idempotency-key-123';
    const testAmount = 1000;
    const testCurrency = 'XOF';
    const testTerminalId = 1;
    const testMerchantId = 1;

    final testLinkResponse = StripeLinkToPayResponse(
      transactionRef: 'ref-123',
      paymentLink: 'https://payment-link.com',
    );

    test('should generate idempotency key on first payment attempt', () async {
      // Arrange
      when(() => mockIdempotencyKeyManager.generateKey())
          .thenReturn(testIdempotencyKey);
      when(() => mockInitLinkPayment(
            amount: any(named: 'amount'),
            idempotencyKey: any(named: 'idempotencyKey'),
          )).thenAnswer((_) async => Right(testLinkResponse));

      // Act
      bloc.add(StripeInitPaymentLinkEvent(
        amount: testAmount,
        currency: testCurrency,
        terminalId: testTerminalId,
        merchantId: testMerchantId,
      ));
      await Future.delayed(Duration.zero);

      // Assert
      verify(() => mockIdempotencyKeyManager.generateKey()).called(1);
      verify(() => mockInitLinkPayment(
            amount: testAmount,
            idempotencyKey: testIdempotencyKey,
          )).called(1);
    });

    blocTest<StripePaymentBloc, StripePaymentState>(
      'should use same idempotency key on retry after network error',
      build: () {
        when(() => mockIdempotencyKeyManager.generateKey())
            .thenReturn(testIdempotencyKey);
        when(() => mockInitLinkPayment(
              amount: any(named: 'amount'),
              idempotencyKey: any(named: 'idempotencyKey'),
            )).thenAnswer(
          (_) async => Left(NetworkFailure()),
        );
        return bloc;
      },
      act: (bloc) {
        // Premier essai
        bloc.add(StripeInitPaymentLinkEvent(
          amount: testAmount,
          currency: testCurrency,
          terminalId: testTerminalId,
          merchantId: testMerchantId,
        ));
      },
      wait: Duration(milliseconds: 100),
      verify: (_) {
        // Vérifie que la clé a été générée UNE SEULE fois
        verify(() => mockIdempotencyKeyManager.generateKey()).called(1);
        verify(() => mockInitLinkPayment(
              amount: testAmount,
              idempotencyKey: testIdempotencyKey,
            )).called(1);
      },
    );

    blocTest<StripePaymentBloc, StripePaymentState>(
      'should reset idempotency key after successful payment',
      build: () {
        when(() => mockIdempotencyKeyManager.generateKey())
            .thenReturn(testIdempotencyKey);
        when(() => mockInitLinkPayment(
              amount: any(named: 'amount'),
              idempotencyKey: any(named: 'idempotencyKey'),
            )).thenAnswer((_) async => Right(testLinkResponse));
        return bloc;
      },
      act: (bloc) {
        bloc.add(StripeInitPaymentLinkEvent(
          amount: testAmount,
          currency: testCurrency,
          terminalId: testTerminalId,
          merchantId: testMerchantId,
        ));
      },
      expect: () => [
        StripePaymentLoading(),
        LinkPaymentQrReady(
          transactionRef: 'ref-123',
          paymentLink: 'https://payment-link.com',
        ),
      ],
      verify: (_) {
        // Clé générée et utilisée
        verify(() => mockIdempotencyKeyManager.generateKey()).called(1);
        verify(() => mockInitLinkPayment(
              amount: testAmount,
              idempotencyKey: testIdempotencyKey,
            )).called(1);
      },
    );

    blocTest<StripePaymentBloc, StripePaymentState>(
      'should generate new idempotency key for second payment after success',
      build: () {
        // Configure two separate calls to return different keys
        var callCount = 0;
        when(() => mockIdempotencyKeyManager.generateKey()).thenAnswer((_) {
          callCount++;
          return callCount == 1 ? 'key-1' : 'key-2';
        });
        when(() => mockInitLinkPayment(
              amount: any(named: 'amount'),
              idempotencyKey: any(named: 'idempotencyKey'),
            )).thenAnswer((_) async => Right(testLinkResponse));
        return bloc;
      },
      act: (bloc) async {
        // Premier paiement
        bloc.add(StripeInitPaymentLinkEvent(
          amount: testAmount,
          currency: testCurrency,
          terminalId: testTerminalId,
          merchantId: testMerchantId,
        ));
        await Future.delayed(Duration(milliseconds: 100));

        // Deuxième paiement
        bloc.add(StripeInitPaymentLinkEvent(
          amount: testAmount,
          currency: testCurrency,
          terminalId: testTerminalId,
          merchantId: testMerchantId,
        ));
      },
      verify: (_) {
        // Deux clés différentes générées
        verify(() => mockIdempotencyKeyManager.generateKey()).called(2);
        verify(() => mockInitLinkPayment(
              amount: testAmount,
              idempotencyKey: 'key-1',
            )).called(1);
        verify(() => mockInitLinkPayment(
              amount: testAmount,
              idempotencyKey: 'key-2',
            )).called(1);
      },
    );

    blocTest<StripePaymentBloc, StripePaymentState>(
      'should keep same key on error for potential retry',
      build: () {
        when(() => mockIdempotencyKeyManager.generateKey())
            .thenReturn(testIdempotencyKey);
        when(() => mockInitLinkPayment(
              amount: any(named: 'amount'),
              idempotencyKey: any(named: 'idempotencyKey'),
            )).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Server error')),
        );
        return bloc;
      },
      act: (bloc) {
        bloc.add(StripeInitPaymentLinkEvent(
          amount: testAmount,
          currency: testCurrency,
          terminalId: testTerminalId,
          merchantId: testMerchantId,
        ));
      },
      expect: () => [
        StripePaymentLoading(),
        StripePaymentError('Server error'),
      ],
      verify: (_) {
        // Clé générée mais pas réinitialisée (pour retry)
        verify(() => mockIdempotencyKeyManager.generateKey()).called(1);
      },
    );
  });
}
