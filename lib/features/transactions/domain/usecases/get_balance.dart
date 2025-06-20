import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:todouapp/features/transactions/data/models/balance_model.dart';

class GetBalance {
  final TransactionRepository repository;

  GetBalance(this.repository);

  Future<Either<Failure, BalanceModel>> call() async {
    return await repository.getBalance();
  }
}
