import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/payments/data/models/stripe_payment_intent_response.dart';

import '../repositories/stripe_payment_repository.dart';

class InitLinkPayment {
  final StripePaymentRepository repository;

  InitLinkPayment(this.repository);

  Future<Either<Failure, StripeLinkToPayResponse>> call(
    StripeLinkPaymentInitRequest request,
  ) async {
    return await repository.initPayLink(request);
  }
}
