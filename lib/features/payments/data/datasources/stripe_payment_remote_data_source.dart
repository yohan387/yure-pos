import 'dart:developer';
import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/secure_storage.dart';
import 'i_stripe_payment_data_source.dart';
import '../models/stripe_payment_intent_response.dart';

class StripePaymentRemoteDataSource implements IStripePaymentDataSource {
  final ApiClient _apiClient;

  StripePaymentRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<StripePaymentIntentResponse> createPaymentIntent(int amount) async {
    try {
      final secureStorage = SecureStorageService();
      final marchantId = await secureStorage.getMarchandId();
      final terminalId = await secureStorage.getTerminalId();

      final response = await _apiClient.post(ApiConstants.stripePaymentIntent,
          body: {
            'amount': amount,
            'currency': 'EUR',
            "terminal_id": int.parse('$terminalId'),
            "merchant_id": int.parse('$marchantId')
          },
          requiresAuth: true);

      log('response create payment intent: $response');
      return StripePaymentIntentResponse.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to create payment intent');
    }
  }

  @override
  Future<StripeLinkToPayResponse> createLinkPayment(int amount) async {
    try {
      final secureStorage = SecureStorageService();
      final marchantId = await secureStorage.getMarchandId();
      final terminalId = await secureStorage.getTerminalId();

      final response = await _apiClient.post(ApiConstants.stripeLinkPaymentInit,
          body: {
            'amount': amount,
            'currency': 'EUR',
            "terminal_id": int.parse('$terminalId'),
            "merchant_id": int.parse('$marchantId')
          },
          requiresAuth: true);

      log('response create link payment: $response');
      return StripeLinkToPayResponse.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to create link payment');
    }
  }
}
