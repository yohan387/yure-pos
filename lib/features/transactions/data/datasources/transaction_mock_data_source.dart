import 'package:todouapp/core/mock/mock_data.dart';
import 'package:todouapp/core/mock/mock_helpers.dart';
import 'package:todouapp/features/transactions/data/datasources/i_transaction_data_source.dart';
import 'package:todouapp/features/transactions/data/models/balance_model.dart';
import 'package:todouapp/features/transactions/data/models/cancel_response.dart';
import 'package:todouapp/features/transactions/data/models/transactions_response_model.dart';
import 'package:todouapp/features/transactions/data/models/transaction_model.dart';

/// Implémentation Mock de ITransactionDataSource
/// Retourne des données fictives sans appels API
class TransactionMockDataSource implements ITransactionDataSource {
  @override
  Future<BalanceModel> getBalance() async {
    await MockHelpers.simulateNetworkDelay();

    return BalanceModel.fromJson(MockData.mockBalance);
  }

  @override
  Future<TransactionsResponseModel> getTransactions({
    int page = 1,
    int limit = 10,
    String? search,
  }) async {
    await MockHelpers.simulateNetworkDelay();

    // Simuler la recherche si fournie
    var transactions = List<Map<String, dynamic>>.from(MockData.mockTransactions);

    if (search != null && search.isNotEmpty) {
      transactions = transactions.where((txn) {
        final description = (txn['description'] ?? '').toString().toLowerCase();
        final method = (txn['payment_method'] ?? '').toString().toLowerCase();
        return description.contains(search.toLowerCase()) ||
            method.contains(search.toLowerCase());
      }).toList();
    }

    // Simuler la pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    final paginatedTransactions = transactions.sublist(
      startIndex.clamp(0, transactions.length),
      endIndex.clamp(0, transactions.length),
    );

    final transactionModels = paginatedTransactions
        .map((json) => TransactionModel.fromJson(json))
        .toList();

    final loadedCount = page * limit;
    final hasMore = loadedCount < transactions.length;

    return TransactionsResponseModel(
      transactions: transactionModels,
      total: transactions.length,
      page: page,
      limit: limit,
      hasMore: hasMore,
    );
  }

  @override
  Future<CancelPaymentResponse> cancelTransaction(String reference) async {
    await MockHelpers.simulateNetworkDelay();

    return CancelPaymentResponse.fromJson({
      "success": true,
      "message": "Transaction annulée avec succès",
      "data": {
        "reference": reference,
        "status": "cancelled",
        "cancelled_at": DateTime.now().toIso8601String(),
      },
    });
  }
}
