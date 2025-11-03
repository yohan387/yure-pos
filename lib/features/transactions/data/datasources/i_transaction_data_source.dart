import 'package:todouapp/features/transactions/data/models/balance_model.dart';
import 'package:todouapp/features/transactions/data/models/cancel_response.dart';
import 'package:todouapp/features/transactions/data/models/transactions_response_model.dart';

/// Interface pour les sources de données de transactions
/// Implémentations: TransactionRemoteDataSource (API), TransactionMockDataSource (Mock)
abstract interface class ITransactionDataSource {
  /// Récupère le solde du terminal
  /// Lance ServerException en cas d'erreur
  Future<BalanceModel> getBalance();

  /// Récupère la liste des transactions avec pagination
  /// [page] - numéro de la page (défaut: 1)
  /// [limit] - nombre d'éléments par page (défaut: 10)
  /// [search] - critère de recherche optionnel
  /// Lance ServerException en cas d'erreur
  Future<TransactionsResponseModel> getTransactions({
    int page = 1,
    int limit = 10,
    String? search,
  });

  /// Annule une transaction en cours
  /// [reference] - référence de la transaction à annuler
  /// Lance ServerException en cas d'erreur
  Future<CancelPaymentResponse> cancelTransaction(String reference);
}
