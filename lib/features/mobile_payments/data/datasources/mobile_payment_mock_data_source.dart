import 'package:todouapp/core/mock/mock_data.dart';
import 'package:todouapp/core/mock/mock_helpers.dart';
import 'package:todouapp/features/mobile_payments/data/datasources/i_mobile_payment_data_source.dart';
import '../models/mobile_payment_model.dart';

class MobilePaymentMockDataSource implements IMobilePaymentDataSource {
  @override
  Future<MobilePaymentInitResponse> initPayment(
      MobilePaymentInitRequest request) async {
    await MockHelpers.simulateNetworkDelay();

    // Utiliser les vraies propriétés du modèle: network, customerPhone
    final mockData = MockData.mockMobilePaymentInit(
      amount: request.amount,
      paymentMethod: request.network,  // Le modèle utilise 'network' pas 'paymentMethod'
      customerPhone: request.customerPhone,
    );

    return MobilePaymentInitResponse.fromJson(mockData);
  }

  @override
  Future<MobilePaymentVerifyResponse> verifyPayment(
      String transactionId) async {
    await MockHelpers.simulateNetworkDelay(minMs: 2000, maxMs: 3000);

    final mockData = MockData.mockMobilePaymentVerification(
      transactionId: transactionId,
      success: true,
    );

    return MobilePaymentVerifyResponse.fromJson(mockData);
  }

  @override
  Future<MobilePaymentVerifyResponse> stripeVerifyPayment(
      String transactionId) async {
    await MockHelpers.simulateNetworkDelay(minMs: 2000, maxMs: 3000);

    final mockData = MockData.mockMobilePaymentVerification(
      transactionId: transactionId,
      success: true,
    );

    return MobilePaymentVerifyResponse.fromJson(mockData);
  }
}
