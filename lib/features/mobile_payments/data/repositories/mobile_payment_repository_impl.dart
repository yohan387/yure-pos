import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/api_client.dart';
import 'package:todouapp/core/network/network_info.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/mobile_payment_repository.dart';
import '../models/mobile_payment_model.dart';

class PaymentRepositoryImpl implements MobilePaymentRepository {
  final ApiClient apiClient;
  final NetworkInfo networkInfo;

  PaymentRepositoryImpl({
    required this.apiClient,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, MobilePaymentInitResponse>> initPayment(
      MobilePaymentInitRequest request) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    log('proccessing .... ${ApiConstants.mobilePaymentInitEndpoint}');
    log('body ${request.toJson()}');
    try {
      final response = await apiClient.post(
          ApiConstants.mobilePaymentInitEndpoint,
          body: request.toJson(),
          requiresAuth: true);
      log('sucess payment $response');
      return Right(MobilePaymentInitResponse.fromJson(response));
    } on ServerException catch (e) {
      log('on payment ${e.message}');
      // Étape 1 : extraire la partie JSON depuis detail
      final pattern = RegExp(r'400: (.+)');
      final match = pattern.firstMatch(e.message);
      if (match != null) {
        final jsonStr = match.group(1);
        try {
          final decoded = jsonDecode(jsonStr!);
          final message = decoded['message'] ?? "Une erreur s'est produite";
          return Left(ServerFailure(message: message));
        } catch (_) {
          return Left(ServerFailure(message: e.message));
        }
      }
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      log('error payment $e');

      return Left(ServerFailure(message: 'Une erreur inattendue est survenue'));
    }
  }

  @override
  Future<Either<Failure, MobilePaymentVerifyResponse>> verifyPayment(
      String transactionId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    log('${ApiConstants.mobilePaymentInitEndpoint}/check-status/$transactionId');

    try {
      final response = await apiClient.get(
          '${ApiConstants.mobilePaymentInitEndpoint}/check-status/$transactionId',
          requiresAuth: true);

      return Right(MobilePaymentVerifyResponse.fromJson(response));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      log('error verify $e');

      return Left(ServerFailure(message: 'Une erreur inattendue est survenue'));
    }
  }
}
