import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';

import '../../data/models/mobile_payment_model.dart';
import '../repositories/i_mobile_payment_repository.dart';

class InitPayment {
  final IMobilePaymentRepository _repository;

  InitPayment(IMobilePaymentRepository repository) : _repository = repository;

  Future<Either<Failure, MobilePaymentInitResponse>> call({
    required MobilePaymentInitRequest request,
    required String idempotencyKey,
  }) async {
    return await _repository.initPayment(
      request: request,
      idempotencyKey: idempotencyKey,
    );
  }
}
