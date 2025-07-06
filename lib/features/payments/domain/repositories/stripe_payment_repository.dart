import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/payments/data/models/stripe_payment_intent_response.dart';

abstract class StripePaymentRepository {
  Future<Either<Failure, StripePaymentIntentResponse>> createPaymentIntent(
      int amount);
}
