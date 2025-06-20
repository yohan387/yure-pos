import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/network_info.dart';
import 'package:todouapp/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:todouapp/features/transactions/data/models/balance_model.dart';
import 'package:todouapp/features/transactions/data/models/transactions_response_model.dart';
import 'package:todouapp/features/transactions/domain/repositories/transaction_repository.dart';

import '../../../../core/errors/exceptions.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, BalanceModel>> getBalance() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final balance = await remoteDataSource.getBalance();
      return Right(balance);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TransactionsResponseModel>> getTransactions({
    int page = 1,
    int limit = 10,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final transactions = await remoteDataSource.getTransactions(
        page: page,
        limit: limit,
      );
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
