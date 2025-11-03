import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';

import '../../data/models/mobile_payment_model.dart';
import '../repositories/i_mobile_payment_repository.dart';

class VerifyPayment {
  final IMobilePaymentRepository _repository;

  VerifyPayment(IMobilePaymentRepository repository) : _repository = repository;

  Future<Either<Failure, MobilePaymentVerifyResponse>> call(
    String transactionId,
  ) async {
    return await _repository.verifyPayment(transactionId);
  }
}
