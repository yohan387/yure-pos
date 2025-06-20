class MobilePaymentInitRequest {
  final double amount;
  final String currency;
  final int terminalId, merchantId;
  final String network;
  final String customerPhone;
  final String operatorOtp;

  MobilePaymentInitRequest({
    required this.amount,
    required this.currency,
    required this.terminalId,
    required this.merchantId,
    required this.network,
    required this.customerPhone,
    required this.operatorOtp,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'terminal_id': terminalId,
        'merchant_id': merchantId,
        'network': network,
        'customer_phone': customerPhone,
        'operator_otp': operatorOtp,
      };
}

class MobilePaymentInitResponse {
  final String paymentUrl;
  final String transactionId;
  final String reference;

  MobilePaymentInitResponse(
      {required this.paymentUrl,
      required this.transactionId,
      required this.reference});

  factory MobilePaymentInitResponse.fromJson(Map<String, dynamic> json) {
    return MobilePaymentInitResponse(
        paymentUrl: json['payment_url_operator'] ?? '',
        transactionId: json['transaction_ref'],
        reference: json['transaction_ref']);
  }
}

class MobilePaymentVerifyResponse {
  final String status;
  final String reference;
  final DateTime date;

  MobilePaymentVerifyResponse({
    required this.status,
    required this.reference,
    required this.date,
  });

  factory MobilePaymentVerifyResponse.fromJson(Map<String, dynamic> json) {
    return MobilePaymentVerifyResponse(
      status: json['status'],
      reference: json['transaction_ref'],
      date: DateTime.parse(json['created_at']),
    );
  }
}
