import 'package:todouapp/core/mock/mock_data.dart';
import 'package:todouapp/core/mock/mock_helpers.dart';
import 'i_stripe_payment_data_source.dart';
import '../models/stripe_payment_intent_response.dart';

class StripePaymentMockDataSource implements IStripePaymentDataSource {
  @override
  Future<StripePaymentIntentResponse> createPaymentIntent({
    required int amount,
    required String idempotencyKey,
  }) async {
    await MockHelpers.simulateNetworkDelay();
    // En mode mock, on log la clé d'idempotence pour vérification
    // ignore: avoid_print
    print('[MOCK] Stripe Payment Intent with idempotency key: $idempotencyKey');
    return StripePaymentIntentResponse.fromJson(
        MockData.mockStripePaymentIntent(amount.toDouble()));
  }

  @override
  Future<StripeLinkToPayResponse> createLinkPayment({
    required int amount,
    required String idempotencyKey,
  }) async {
    await MockHelpers.simulateNetworkDelay();
    // En mode mock, on log la clé d'idempotence pour vérification
    // ignore: avoid_print
    print('[MOCK] Stripe Link Payment with idempotency key: $idempotencyKey');
    return StripeLinkToPayResponse.fromJson(
        MockData.mockStripeLinkPayment(amount.toDouble()));
  }
}
