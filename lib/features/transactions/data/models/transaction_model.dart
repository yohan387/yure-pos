class TransactionModel {
  final int id;
  final int merchantId;
  final int terminalId;
  final double amount;
  final String currency;
  final String transactionRef;
  final DateTime date;
  final String paymentMethod;
  final String status;
  final String customerPhone;
  final String network;

  TransactionModel({
    required this.id,
    required this.merchantId,
    required this.terminalId,
    required this.amount,
    required this.currency,
    required this.transactionRef,
    required this.date,
    required this.paymentMethod,
    required this.status,
    required this.customerPhone,
    required this.network,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? '',
      date: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at']),
      status: json['status'] ?? '',
      merchantId: json['merchant_id'] ?? 0,
      terminalId: json['terminal_id'] ?? 0,
      transactionRef: json['transaction_ref'] ?? '',
      paymentMethod: json['payment_method'] ?? 'Mobile Money',
      customerPhone: json['customer_phone'] ?? '',
      network: json['network'] ?? '',
    );
  }
}
