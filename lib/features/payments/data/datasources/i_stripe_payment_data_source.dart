import '../models/stripe_payment_intent_response.dart';

abstract interface class IStripePaymentDataSource {
  Future<StripePaymentIntentResponse> createPaymentIntent({
    required int amount,
    required String idempotencyKey,
  });
  Future<StripeLinkToPayResponse> createLinkPayment({
    required int amount,
    required String idempotencyKey,
  });
}
