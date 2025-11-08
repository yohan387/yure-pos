import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import '../../data/models/stripe_payment_intent_response.dart';

import '../repositories/i_stripe_payment_repository.dart';

class InitLinkPayment {
  final IStripePaymentRepository _repository;

  InitLinkPayment(IStripePaymentRepository repository) : _repository = repository;

  Future<Either<Failure, StripeLinkToPayResponse>> call({
    required int amount,
    required String idempotencyKey,
  }) async {
    return await _repository.createLinkPayment(
      amount: amount,
      idempotencyKey: idempotencyKey,
    );
  }
}
