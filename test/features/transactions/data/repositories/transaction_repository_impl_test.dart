import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/i_network_info.dart';
import 'package:todouapp/features/transactions/data/datasources/i_transaction_data_source.dart';
import 'package:todouapp/features/transactions/data/models/balance_model.dart';
import 'package:todouapp/features/transactions/data/models/cancel_response.dart';
import 'package:todouapp/features/transactions/data/models/transaction_model.dart';
import 'package:todouapp/features/transactions/data/models/transactions_response_model.dart';
import 'package:todouapp/features/transactions/data/repositories/transaction_repository_impl.dart';

class MockTransactionDataSource extends Mock implements ITransactionDataSource {}

class MockNetworkInfo extends Mock implements INetworkInfo {}

void main() {
  late TransactionRepositoryImpl repository;
  late MockTransactionDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockDataSource = MockTransactionDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = TransactionRepositoryImpl(
      dataSource: mockDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('TransactionRepositoryImpl', () {
    group('getBalance', () {
      final tBalanceModel = BalanceModel(
        amount: 1250000.0,
        currency: 'XOF',
      );

      test('should check if the device is online', () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.getBalance()).thenAnswer((_) async => tBalanceModel);

        // act
        await repository.getBalance();

        // assert
        verify(() => mockNetworkInfo.isConnected);
      });

      group('device is online', () {
        setUp(() {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });

        test('should return BalanceModel when the call to dataSource is successful', () async {
          // arrange
          when(() => mockDataSource.getBalance()).thenAnswer((_) async => tBalanceModel);

          // act
          final result = await repository.getBalance();

          // assert
          verify(() => mockDataSource.getBalance());
          expect(result, equals(Right(tBalanceModel)));
        });

        test('should return ServerFailure when dataSource throws ServerException', () async {
          // arrange
          when(() => mockDataSource.getBalance())
              .thenThrow(ServerException(message: 'Server error'));

          // act
          final result = await repository.getBalance();

          // assert
          verify(() => mockDataSource.getBalance());
          expect(result, equals(Left(ServerFailure(message: 'Server error'))));
        });

        test('should return ServerFailure with custom message', () async {
          // arrange
          when(() => mockDataSource.getBalance())
              .thenThrow(ServerException(message: 'Balance not found'));

          // act
          final result = await repository.getBalance();

          // assert
          expect(result, equals(Left(ServerFailure(message: 'Balance not found'))));
        });
      });

      group('device is offline', () {
        test('should return NetworkFailure when device is offline', () async {
          // arrange
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

          // act
          final result = await repository.getBalance();

          // assert
          verifyNever(() => mockDataSource.getBalance());
          expect(result, equals(Left(NetworkFailure())));
        });
      });
    });

    group('getTransactions', () {
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

      const tPage = 1;
      const tLimit = 10;
      const tSearch = 'TXN';

      test('should check if the device is online', () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.getTransactions(
              page: any(named: 'page'),
              limit: any(named: 'limit'),
              search: any(named: 'search'),
            )).thenAnswer((_) async => tTransactionsResponse);

        // act
        await repository.getTransactions(page: tPage, limit: tLimit, search: tSearch);

        // assert
        verify(() => mockNetworkInfo.isConnected);
      });

      group('device is online', () {
        setUp(() {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });

        test('should return TransactionsResponseModel when call is successful', () async {
          // arrange
          when(() => mockDataSource.getTransactions(
                page: tPage,
                limit: tLimit,
                search: tSearch,
              )).thenAnswer((_) async => tTransactionsResponse);

          // act
          final result = await repository.getTransactions(
            page: tPage,
            limit: tLimit,
            search: tSearch,
          );

          // assert
          verify(() => mockDataSource.getTransactions(
                page: tPage,
                limit: tLimit,
                search: tSearch,
              ));
          expect(result, equals(Right(tTransactionsResponse)));
        });

        test('should return transactions with default parameters', () async {
          // arrange
          when(() => mockDataSource.getTransactions(
                page: 1,
                limit: 10,
                search: null,
              )).thenAnswer((_) async => tTransactionsResponse);

          // act
          final result = await repository.getTransactions();

          // assert
          verify(() => mockDataSource.getTransactions(
                page: 1,
                limit: 10,
                search: null,
              ));
          expect(result, equals(Right(tTransactionsResponse)));
        });

        test('should pass only page and limit without search', () async {
          // arrange
          when(() => mockDataSource.getTransactions(
                page: 2,
                limit: 20,
                search: null,
              )).thenAnswer((_) async => tTransactionsResponse);

          // act
          final result = await repository.getTransactions(page: 2, limit: 20);

          // assert
          verify(() => mockDataSource.getTransactions(
                page: 2,
                limit: 20,
                search: null,
              ));
          expect(result, equals(Right(tTransactionsResponse)));
        });

        test('should return ServerFailure when dataSource throws ServerException', () async {
          // arrange
          when(() => mockDataSource.getTransactions(
                page: any(named: 'page'),
                limit: any(named: 'limit'),
                search: any(named: 'search'),
              )).thenThrow(ServerException(message: 'Failed to fetch transactions'));

          // act
          final result = await repository.getTransactions(
            page: tPage,
            limit: tLimit,
            search: tSearch,
          );

          // assert
          expect(result, equals(Left(ServerFailure(message: 'Failed to fetch transactions'))));
        });

        test('should return ServerFailure with 404 error message', () async {
          // arrange
          when(() => mockDataSource.getTransactions(
                page: any(named: 'page'),
                limit: any(named: 'limit'),
                search: any(named: 'search'),
              )).thenThrow(ServerException(message: 'Transactions not found', statusCode: 404));

          // act
          final result = await repository.getTransactions();

          // assert
          expect(result, equals(Left(ServerFailure(message: 'Transactions not found'))));
        });
      });

      group('device is offline', () {
        test('should return NetworkFailure when device is offline', () async {
          // arrange
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

          // act
          final result = await repository.getTransactions(
            page: tPage,
            limit: tLimit,
            search: tSearch,
          );

          // assert
          verifyNever(() => mockDataSource.getTransactions(
                page: any(named: 'page'),
                limit: any(named: 'limit'),
                search: any(named: 'search'),
              ));
          expect(result, equals(Left(NetworkFailure())));
        });
      });
    });

    group('cancelTransaction', () {
      const tReference = 'TXN123456';
      final tCancelResponse = CancelPaymentResponse(
        message: 'Transaction cancelled successfully',
      );

      test('should check if the device is online', () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.cancelTransaction(any()))
            .thenAnswer((_) async => tCancelResponse);

        // act
        await repository.cancelTransaction(tReference);

        // assert
        verify(() => mockNetworkInfo.isConnected);
      });

      group('device is online', () {
        setUp(() {
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        });

        test('should return CancelPaymentResponse when call is successful', () async {
          // arrange
          when(() => mockDataSource.cancelTransaction(tReference))
              .thenAnswer((_) async => tCancelResponse);

          // act
          final result = await repository.cancelTransaction(tReference);

          // assert
          verify(() => mockDataSource.cancelTransaction(tReference));
          expect(result, equals(Right(tCancelResponse)));
        });

        test('should pass the correct reference to dataSource', () async {
          // arrange
          const customReference = 'CUSTOM_REF_999';
          when(() => mockDataSource.cancelTransaction(customReference))
              .thenAnswer((_) async => tCancelResponse);

          // act
          await repository.cancelTransaction(customReference);

          // assert
          verify(() => mockDataSource.cancelTransaction(customReference));
        });

        test('should return ServerFailure when dataSource throws ServerException', () async {
          // arrange
          when(() => mockDataSource.cancelTransaction(any()))
              .thenThrow(ServerException(message: 'Transaction not found'));

          // act
          final result = await repository.cancelTransaction(tReference);

          // assert
          verify(() => mockDataSource.cancelTransaction(tReference));
          expect(result, equals(Left(ServerFailure(message: 'Transaction not found'))));
        });

        test('should return ServerFailure with custom error message', () async {
          // arrange
          when(() => mockDataSource.cancelTransaction(any()))
              .thenThrow(ServerException(message: 'Cannot cancel completed transaction'));

          // act
          final result = await repository.cancelTransaction(tReference);

          // assert
          expect(
              result, equals(Left(ServerFailure(message: 'Cannot cancel completed transaction'))));
        });
      });

      group('device is offline', () {
        test('should return NetworkFailure when device is offline', () async {
          // arrange
          when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

          // act
          final result = await repository.cancelTransaction(tReference);

          // assert
          verifyNever(() => mockDataSource.cancelTransaction(any()));
          expect(result, equals(Left(NetworkFailure())));
        });
      });
    });
  });
}
