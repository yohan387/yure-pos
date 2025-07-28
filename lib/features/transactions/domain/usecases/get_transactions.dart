import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:todouapp/features/transactions/data/models/transactions_response_model.dart';

class GetTransactions {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  Future<Either<Failure, TransactionsResponseModel>> call(Params params) async {
    return await repository.getTransactions(
      page: params.page,
      limit: params.limit,
      search: params.search,
    );
  }
}

class Params {
  final int page;
  final int limit;
  final String? search;

  Params({
    required this.page,
    required this.limit,
    this.search,
  });
}
