import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';

import '../../data/models/mobile_payment_model.dart';
import '../repositories/mobile_payment_repository.dart';

class InitPayment {
  final MobilePaymentRepository repository;

  InitPayment(this.repository);

  Future<Either<Failure, MobilePaymentInitResponse>> call(
    MobilePaymentInitRequest request,
  ) async {
    return await repository.initPayment(request);
  }
}
