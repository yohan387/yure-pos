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
  static const stripeKey =
      "pk_test_51RTjXa2a6jwmtn5fKrCVI57JiXibY3sFts75CltLoA6UhQEB2EISs4biH7MmkcBEu611axqQoItyREtMPFijWiZr00X6wjAUIH";

  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
