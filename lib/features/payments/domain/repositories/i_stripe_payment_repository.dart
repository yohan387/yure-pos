import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import '../../data/models/stripe_payment_intent_response.dart';

abstract class IStripePaymentRepository {
  Future<Either<Failure, StripePaymentIntentResponse>> createPaymentIntent({
    required int amount,
    required String idempotencyKey,
  });
  Future<Either<Failure, StripeLinkToPayResponse>> createLinkPayment({
    required int amount,
    required String idempotencyKey,
  });
}
