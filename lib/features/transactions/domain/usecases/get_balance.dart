import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/transactions/domain/repositories/i_transaction_repository.dart';
import 'package:todouapp/features/transactions/data/models/balance_model.dart';

class GetBalance {
  final ITransactionRepository _repository;

  GetBalance(ITransactionRepository repository) : _repository = repository;

  Future<Either<Failure, BalanceModel>> call() async {
    return await _repository.getBalance();
  }
}
