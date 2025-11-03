import '../models/stripe_payment_intent_response.dart';

abstract interface class IStripePaymentDataSource {
  Future<StripePaymentIntentResponse> createPaymentIntent(int amount);
  Future<StripeLinkToPayResponse> createLinkPayment(int amount);
}
