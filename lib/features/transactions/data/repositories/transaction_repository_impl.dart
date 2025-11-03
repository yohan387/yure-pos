import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/i_network_info.dart';
import 'package:todouapp/features/transactions/data/datasources/i_transaction_data_source.dart';
import 'package:todouapp/features/transactions/data/models/balance_model.dart';
import 'package:todouapp/features/transactions/data/models/cancel_response.dart';
import 'package:todouapp/features/transactions/data/models/transactions_response_model.dart';
import 'package:todouapp/features/transactions/domain/repositories/i_transaction_repository.dart';

import '../../../../core/errors/exceptions.dart';

/// Implémentation du repository de transactions
class TransactionRepositoryImpl implements ITransactionRepository {
  final ITransactionDataSource _dataSource;
  final INetworkInfo _networkInfo;

  TransactionRepositoryImpl({
    required ITransactionDataSource dataSource,
    required INetworkInfo networkInfo,
  })  : _dataSource = dataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, BalanceModel>> getBalance() async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final balance = await _dataSource.getBalance();
      return Right(balance);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TransactionsResponseModel>> getTransactions({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final transactions = await _dataSource.getTransactions(
          page: page, limit: limit, search: search);
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, CancelPaymentResponse>> cancelTransaction(
      String reference) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final response = await _dataSource.cancelTransaction(reference);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
