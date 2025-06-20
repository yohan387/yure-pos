import 'package:todouapp/features/transactions/data/models/transaction_model.dart';

class TransactionsResponseModel {
  final List<TransactionModel> transactions;
  final int total;
  final int page;
  final int limit;
  final bool hasMore;

  TransactionsResponseModel({
    required this.transactions,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory TransactionsResponseModel.fromJson(Map<String, dynamic> json) {
    final transactions = (json['data'] as List)
        .map((e) => TransactionModel.fromJson(e))
        .toList();

    final total = json['total_data'] ?? 0;
    final page = json['current_page'] ?? 1;
    final limit = json['limit'] ?? 5;

    final int loadedCount = page * limit;
    final hasMore = loadedCount < total;

    return TransactionsResponseModel(
      transactions: transactions,
      total: total,
      page: page,
      limit: limit,
      hasMore: hasMore,
    );
  }
}
