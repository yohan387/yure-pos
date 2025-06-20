class StripePaymentIntentResponse {
  final String clientSecret;
  // final String ephemeralKey;
  // final String customerId;
  // final String paymentIntentId;

  StripePaymentIntentResponse({
    required this.clientSecret,
    // required this.ephemeralKey,
    // required this.customerId,
    // required this.paymentIntentId,
  });

  factory StripePaymentIntentResponse.fromJson(Map<String, dynamic> json) {
    return StripePaymentIntentResponse(
      clientSecret: json['client_secret'],
      // ephemeralKey: json['ephemeral_key'],
      // customerId: json['customer_id'],
      // paymentIntentId: json['payment_intent_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'client_secret': clientSecret,
        // 'ephemeral_key': ephemeralKey,
        // 'customer_id': customerId,
        // 'payment_intent_id': paymentIntentId,
      };
}
