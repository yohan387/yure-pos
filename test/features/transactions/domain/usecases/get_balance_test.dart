import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/transactions/data/models/balance_model.dart';
import 'package:todouapp/features/transactions/domain/repositories/i_transaction_repository.dart';
import 'package:todouapp/features/transactions/domain/usecases/get_balance.dart';

class MockTransactionRepository extends Mock implements ITransactionRepository {}

void main() {
  late GetBalance usecase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    usecase = GetBalance(mockRepository);
  });

  group('GetBalance', () {
    final tBalanceModel = BalanceModel(
      amount: 1250000.0,
      currency: 'XOF',
    );

    test('should get balance from the repository', () async {
      // arrange
      when(() => mockRepository.getBalance())
          .thenAnswer((_) async => Right(tBalanceModel));

      // act
      final result = await usecase();

      // assert
      expect(result, Right(tBalanceModel));
      verify(() => mockRepository.getBalance());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Right with BalanceModel on success', () async {
      // arrange
      when(() => mockRepository.getBalance())
          .thenAnswer((_) async => Right(tBalanceModel));

      // act
      final result = await usecase();

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (balance) {
          expect(balance, equals(tBalanceModel));
          expect(balance.amount, equals(1250000.0));
          expect(balance.currency, equals('XOF'));
        },
      );
    });

    test('should return Left with NetworkFailure when no connection', () async {
      // arrange
      when(() => mockRepository.getBalance())
          .thenAnswer((_) async => Left(NetworkFailure()));

      // act
      final result = await usecase();

      // assert
      expect(result, Left(NetworkFailure()));
      verify(() => mockRepository.getBalance());
    });

    test('should return Left with ServerFailure on server error', () async {
      // arrange
      when(() => mockRepository.getBalance())
          .thenAnswer((_) async => Left(ServerFailure(message: 'Server error')));

      // act
      final result = await usecase();

      // assert
      expect(result, Left(ServerFailure(message: 'Server error')));
      verify(() => mockRepository.getBalance());
    });

    test('should forward any failure from repository', () async {
      // arrange
      const tFailure = ServerFailure(message: 'Balance not found');
      when(() => mockRepository.getBalance())
          .thenAnswer((_) async => Left(tFailure));

      // act
      final result = await usecase();

      // assert
      expect(result, Left(tFailure));
      verify(() => mockRepository.getBalance());
    });
  });
}
