import 'package:todouapp/core/mock/mock_data.dart';
import 'package:todouapp/core/mock/mock_helpers.dart';
import 'i_stripe_payment_data_source.dart';
import '../models/stripe_payment_intent_response.dart';

class StripePaymentMockDataSource implements IStripePaymentDataSource {
  @override
  Future<StripePaymentIntentResponse> createPaymentIntent(int amount) async {
    await MockHelpers.simulateNetworkDelay();
    return StripePaymentIntentResponse.fromJson(
        MockData.mockStripePaymentIntent(amount.toDouble()));
  }

  @override
  Future<StripeLinkToPayResponse> createLinkPayment(int amount) async {
    await MockHelpers.simulateNetworkDelay();
    return StripeLinkToPayResponse.fromJson(
        MockData.mockStripeLinkPayment(amount.toDouble()));
  }
}
