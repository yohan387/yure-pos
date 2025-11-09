class ApiConstants {
  static const String baseUrl =
      'https://tyure-backend-dev.todoustudio.cloud/api/v1';
  static const String loginEndpoint = '/merchants/terminals/request-otp';
  static const String emailLoginEndpoint = '/auth/email-login';
  static const String resendEmailOtpEndpoint = '/auth/resend-email-otp';
  static const String verifyEmailOtpEndpoint = '/auth/verify-email-otp';
  static const String verifyOtpEndpoint = '/merchants/terminals/verify-otp';
  static const String merchantTerminalsEndpoint = '/api/merchant/terminals';
  static const String balanceEndpoint = '/auth/merchants/';
  static const String transactionsEndpoint = '/auth/merchants/';
  static const String mobilePaymentInitEndpoint =
      '/merchants/transactions/init-payment/mobile-money';

  static const String stripePaymentIntent =
      '/merchants/transactions/init-payment/card';

  static const String stripeLinkPaymentInit =
      '/merchants/transactions/init-payment/card/link';

  // static const String verifyPaymentLink =
  //     '/merchants/transactions/init-payment/card/link';

  static const String stripePaymentCancel =
      '/merchants/transactions/init-payment/card/cancel';

  static const Duration connectionTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
