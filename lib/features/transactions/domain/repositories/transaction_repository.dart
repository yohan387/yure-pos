import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/transactions/data/models/balance_model.dart';
import 'package:todouapp/features/transactions/data/models/cancel_response.dart';
import 'package:todouapp/features/transactions/data/models/transactions_response_model.dart';

abstract class TransactionRepository {
  Future<Either<Failure, BalanceModel>> getBalance();
  Future<Either<Failure, TransactionsResponseModel>> getTransactions({
    int page,
    int limit,
    String? search,
  });
  Future<Either<Failure, CancelPaymentResponse>> cancelTransaction(reference);
}
