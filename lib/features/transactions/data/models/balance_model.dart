class BalanceModel {
  final double amount;
  final String currency;

  BalanceModel({
    required this.amount,
    required this.currency,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      amount: (json['total_balance'] as num).toDouble(),
      currency: json['currency'] ?? 'Fcfa',
    );
  }
}
