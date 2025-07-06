class ApiConstants {
  static const String baseUrl =
      'https://tyure-backend-dev.todoustudio.cloud/api/v1';
  static const String loginEndpoint = '/merchants/terminals/request-otp';
  static const String verifyOtpEndpoint = '/merchants/terminals/verify-otp';
  static const String balanceEndpoint = '/auth/merchants/';
  static const String transactionsEndpoint = '/auth/merchants/';
  static const String mobilePaymentInitEndpoint =
      '/merchants/transactions/init-payment/mobile-money';

  static const String stripePaymentIntent =
      '/merchants/transactions/init-payment/card';

  static const String stripePaymentCancel =
      '/merchants/transactions/init-payment/card/cancel';

  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
