import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/transactions/data/models/cancel_response.dart';
import 'package:todouapp/features/transactions/domain/repositories/i_transaction_repository.dart';

class GetCancelPayment {
  final ITransactionRepository _repository;

  GetCancelPayment(ITransactionRepository repository) : _repository = repository;

  Future<Either<Failure, CancelPaymentResponse>> call(String reference) async {
    return await _repository.cancelTransaction(reference);
  }
}
