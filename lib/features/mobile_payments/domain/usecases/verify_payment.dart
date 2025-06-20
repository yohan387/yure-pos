import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';

import '../../data/models/mobile_payment_model.dart';
import '../repositories/mobile_payment_repository.dart';

class VerifyPayment {
  final MobilePaymentRepository repository;

  VerifyPayment(this.repository);

  Future<Either<Failure, MobilePaymentVerifyResponse>> call(
    String transactionId,
  ) async {
    return await repository.verifyPayment(transactionId);
  }
}
