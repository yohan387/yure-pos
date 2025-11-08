import 'dart:developer';
import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/network/api_client.dart';
import 'package:todouapp/features/mobile_payments/data/datasources/i_mobile_payment_data_source.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/mobile_payment_model.dart';

class MobilePaymentRemoteDataSource implements IMobilePaymentDataSource {
  final ApiClient _apiClient;

  MobilePaymentRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<MobilePaymentInitResponse> initPayment({
    required MobilePaymentInitRequest request,
    required String idempotencyKey,
  }) async {
    try {
      log('proccessing .... ${ApiConstants.mobilePaymentInitEndpoint}');
      log('body ${request.toJson()}');
      final response = await _apiClient.post(
        ApiConstants.mobilePaymentInitEndpoint,
        body: request.toJson(),
        headers: {
          'X-Idempotency-Key': idempotencyKey,
        },
        requiresAuth: true,
      );
      log('sucess payment $response');
      return MobilePaymentInitResponse.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      log('error payment $e');
      throw ServerException(message: 'Failed to init payment');
    }
  }

  @override
  Future<MobilePaymentVerifyResponse> verifyPayment(
      String transactionId) async {
    try {
      log('${ApiConstants.mobilePaymentInitEndpoint}/check-status/$transactionId');
      final response = await _apiClient.get(
          '${ApiConstants.mobilePaymentInitEndpoint}/check-status/$transactionId',
          requiresAuth: true);
      return MobilePaymentVerifyResponse.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      log('error verify $e');
      throw ServerException(message: 'Failed to verify payment');
    }
  }

  @override
  Future<MobilePaymentVerifyResponse> stripeVerifyPayment(
      String transactionId) async {
    try {
      log('${ApiConstants.mobilePaymentInitEndpoint}/check-status/$transactionId');
      final response = await _apiClient.get(
          '${ApiConstants.mobilePaymentInitEndpoint}/check-status/$transactionId',
          requiresAuth: true);
      return MobilePaymentVerifyResponse.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      log('error verify $e');
      throw ServerException(message: 'Failed to verify stripe payment');
    }
  }
}
