import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/transactions/data/models/cancel_response.dart';
import 'package:todouapp/features/transactions/domain/repositories/i_transaction_repository.dart';
import 'package:todouapp/features/transactions/domain/usecases/get_cancel_payment.dart';

class MockTransactionRepository extends Mock implements ITransactionRepository {}

void main() {
  late GetCancelPayment usecase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    usecase = GetCancelPayment(mockRepository);
  });

  group('GetCancelPayment', () {
    const tReference = 'TXN123456';
    final tCancelResponse = CancelPaymentResponse(
      message: 'Transaction cancelled successfully',
    );

    test('should cancel transaction in repository with correct reference', () async {
      // arrange
      when(() => mockRepository.cancelTransaction(any()))
          .thenAnswer((_) async => Right(tCancelResponse));

      // act
      final result = await usecase(tReference);

      // assert
      expect(result, Right(tCancelResponse));
      verify(() => mockRepository.cancelTransaction(tReference));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Right with CancelPaymentResponse on success', () async {
      // arrange
      when(() => mockRepository.cancelTransaction(any()))
          .thenAnswer((_) async => Right(tCancelResponse));

      // act
      final result = await usecase(tReference);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (response) {
          expect(response, equals(tCancelResponse));
          expect(response.message, equals('Transaction cancelled successfully'));
        },
      );
    });

    test('should pass different reference correctly to repository', () async {
      // arrange
      const customReference = 'CUSTOM_REF_999';
      when(() => mockRepository.cancelTransaction(customReference))
          .thenAnswer((_) async => Right(tCancelResponse));

      // act
      await usecase(customReference);

      // assert
      verify(() => mockRepository.cancelTransaction(customReference));
    });

    test('should return Left with NetworkFailure when no connection', () async {
      // arrange
      when(() => mockRepository.cancelTransaction(any()))
          .thenAnswer((_) async => Left(NetworkFailure()));

      // act
      final result = await usecase(tReference);

      // assert
      expect(result, Left(NetworkFailure()));
      verify(() => mockRepository.cancelTransaction(tReference));
    });

    test('should return Left with ServerFailure on server error', () async {
      // arrange
      when(() => mockRepository.cancelTransaction(any()))
          .thenAnswer((_) async => Left(ServerFailure(message: 'Transaction not found')));

      // act
      final result = await usecase(tReference);

      // assert
      expect(result, Left(ServerFailure(message: 'Transaction not found')));
      verify(() => mockRepository.cancelTransaction(tReference));
    });

    test('should forward any failure from repository', () async {
      // arrange
      const tFailure = ServerFailure(message: 'Cannot cancel completed transaction');
      when(() => mockRepository.cancelTransaction(any()))
          .thenAnswer((_) async => Left(tFailure));

      // act
      final result = await usecase(tReference);

      // assert
      expect(result, Left(tFailure));
      verify(() => mockRepository.cancelTransaction(tReference));
    });
  });
}
