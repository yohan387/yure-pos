import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/transactions/data/models/transaction_model.dart';
import 'package:todouapp/features/transactions/data/models/transactions_response_model.dart';
import 'package:todouapp/features/transactions/domain/repositories/i_transaction_repository.dart';
import 'package:todouapp/features/transactions/domain/usecases/get_transactions.dart';

class MockTransactionRepository extends Mock implements ITransactionRepository {}

void main() {
  late GetTransactions usecase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    usecase = GetTransactions(mockRepository);
  });

  group('GetTransactions', () {
    final tTransactionModel = TransactionModel(
      id: 1,
      merchantId: 100,
      terminalId: 200,
      amount: 5000.0,
      currency: 'XOF',
      transactionRef: 'TXN123',
      date: DateTime.parse('2024-01-15T10:30:00.000Z'),
      paymentMethod: 'Mobile Money',
      status: 'success',
      customerPhone: '+221771234567',
      network: 'Orange Money',
    );

    final tTransactionsResponse = TransactionsResponseModel(
      transactions: [tTransactionModel],
      total: 25,
      page: 1,
      limit: 10,
      hasMore: true,
    );

    final tParams = Params(page: 1, limit: 10, search: 'TXN');

    test('should get transactions from repository with correct parameters', () async {
      // arrange
      when(() => mockRepository.getTransactions(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => Right(tTransactionsResponse));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Right(tTransactionsResponse));
      verify(() => mockRepository.getTransactions(
            page: 1,
            limit: 10,
            search: 'TXN',
          ));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Right with TransactionsResponseModel on success', () async {
      // arrange
      when(() => mockRepository.getTransactions(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => Right(tTransactionsResponse));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (response) {
          expect(response, equals(tTransactionsResponse));
          expect(response.transactions.length, equals(1));
          expect(response.total, equals(25));
          expect(response.hasMore, equals(true));
        },
      );
    });

    test('should handle params without search term', () async {
      // arrange
      final paramsWithoutSearch = Params(page: 2, limit: 20);
      when(() => mockRepository.getTransactions(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => Right(tTransactionsResponse));

      // act
      final result = await usecase(paramsWithoutSearch);

      // assert
      verify(() => mockRepository.getTransactions(
            page: 2,
            limit: 20,
            search: null,
          ));
      expect(result, Right(tTransactionsResponse));
    });

    test('should return Left with NetworkFailure when no connection', () async {
      // arrange
      when(() => mockRepository.getTransactions(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => Left(NetworkFailure()));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Left(NetworkFailure()));
      verify(() => mockRepository.getTransactions(
            page: 1,
            limit: 10,
            search: 'TXN',
          ));
    });

    test('should return Left with ServerFailure on server error', () async {
      // arrange
      when(() => mockRepository.getTransactions(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => Left(ServerFailure(message: 'Server error')));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Left(ServerFailure(message: 'Server error')));
      verify(() => mockRepository.getTransactions(
            page: 1,
            limit: 10,
            search: 'TXN',
          ));
    });

    test('should forward any failure from repository', () async {
      // arrange
      const tFailure = ServerFailure(message: 'Transactions not found');
      when(() => mockRepository.getTransactions(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            search: any(named: 'search'),
          )).thenAnswer((_) async => Left(tFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, Left(tFailure));
      verify(() => mockRepository.getTransactions(
            page: 1,
            limit: 10,
            search: 'TXN',
          ));
    });
  });

  group('Params', () {
    test('should create Params with all fields', () {
      // act
      final params = Params(page: 1, limit: 10, search: 'test');

      // assert
      expect(params.page, equals(1));
      expect(params.limit, equals(10));
      expect(params.search, equals('test'));
    });

    test('should create Params without search field', () {
      // act
      final params = Params(page: 2, limit: 20);

      // assert
      expect(params.page, equals(2));
      expect(params.limit, equals(20));
      expect(params.search, isNull);
    });
  });
}
