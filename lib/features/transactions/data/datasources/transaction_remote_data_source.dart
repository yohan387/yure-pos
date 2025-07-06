import 'dart:developer';

import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/network/api_client.dart';
import 'package:todouapp/features/transactions/data/models/balance_model.dart';
import 'package:todouapp/features/transactions/data/models/cancel_response.dart';
import 'package:todouapp/features/transactions/data/models/transactions_response_model.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/secure_storage.dart';

abstract class TransactionRemoteDataSource {
  Future<BalanceModel> getBalance();
  Future<TransactionsResponseModel> getTransactions(
      {int page = 1, int limit = 10});
  Future<CancelPaymentResponse> cancelTransaction(reference);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final ApiClient apiClient;

  TransactionRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<BalanceModel> getBalance() async {
    try {
      final secureStorage = SecureStorageService();
      final marchantId = await secureStorage.getMarchandId();
      final terminalId = await secureStorage.getTerminalId();
      log('Getting balance loading...');
      log('${ApiConstants.balanceEndpoint}$marchantId/terminals/$terminalId/balance');

      final response = await apiClient.get(
          '${ApiConstants.balanceEndpoint}$marchantId/terminals/$terminalId/balance',
          requiresAuth: true);

      return BalanceModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to fetch balance');
    }
  }

  @override
  Future<TransactionsResponseModel> getTransactions(
      {int page = 1, int limit = 10}) async {
    try {
      log('Transactions loading...');
      final secureStorage = SecureStorageService();
      final marchantId = await secureStorage.getMarchandId();
      final terminalId = await secureStorage.getTerminalId();
      log('${ApiConstants.transactionsEndpoint}$marchantId/terminals/$terminalId/transactions');
      final response = await apiClient.get(
          '${ApiConstants.transactionsEndpoint}$marchantId/terminals/$terminalId/transactions?page=$page&limit=$limit',
          requiresAuth: true);
      return TransactionsResponseModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      log('$e');
      throw ServerException(message: 'Failed to fetch transactions');
    }
  }

  @override
  Future<CancelPaymentResponse> cancelTransaction(reference) async {
    try {
      log('Canceling transaction with reference: $reference');
      final response = await apiClient.post(
          '${ApiConstants.stripePaymentCancel}/$reference',
          requiresAuth: true);
      log('Cancelation response: $response');

      return CancelPaymentResponse.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to cancel transaction');
    }
  }
}
