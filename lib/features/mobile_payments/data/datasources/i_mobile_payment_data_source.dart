import '../models/mobile_payment_model.dart';

/// Interface pour les sources de données de paiements mobiles
abstract interface class IMobilePaymentDataSource {
  Future<MobilePaymentInitResponse> initPayment(
      MobilePaymentInitRequest request);
  Future<MobilePaymentVerifyResponse> verifyPayment(String transactionId);
  Future<MobilePaymentVerifyResponse> stripeVerifyPayment(
      String transactionId);
}
