import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/transactions/data/models/cancel_response.dart';
import 'package:todouapp/features/transactions/domain/repositories/transaction_repository.dart';

class GetCancelPayment {
  final TransactionRepository repository;

  GetCancelPayment(this.repository);

  Future<Either<Failure, CancelPaymentResponse>> call(reference) async {
    return await repository.cancelTransaction(reference);
  }
}
