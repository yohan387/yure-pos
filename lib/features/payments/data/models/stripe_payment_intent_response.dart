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

class StripeLinkPaymentInitRequest {
  final dynamic amount;
  final String currency;
  final int terminalId, merchantId;

  StripeLinkPaymentInitRequest({
    required this.amount,
    required this.currency,
    required this.terminalId,
    required this.merchantId,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'terminal_id': terminalId,
        'merchant_id': merchantId,
      };
}

class StripeLinkToPayResponse {
  final String paymentLink;
  final String transactionRef;

  StripeLinkToPayResponse(
      {required this.paymentLink, required this.transactionRef});

  factory StripeLinkToPayResponse.fromJson(Map<String, dynamic> json) {
    return StripeLinkToPayResponse(
        paymentLink: json['payment_link'] ?? '',
        transactionRef: json['transaction_ref']);
  }
}
