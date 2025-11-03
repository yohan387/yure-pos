import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/i_network_info.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/i_mobile_payment_repository.dart';
import '../datasources/i_mobile_payment_data_source.dart';
import '../models/mobile_payment_model.dart';

class PaymentRepositoryImpl implements IMobilePaymentRepository {
  final IMobilePaymentDataSource _dataSource;
  final INetworkInfo _networkInfo;

  PaymentRepositoryImpl({
    required IMobilePaymentDataSource dataSource,
    required INetworkInfo networkInfo,
  })  : _dataSource = dataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, MobilePaymentInitResponse>> initPayment(
      MobilePaymentInitRequest request) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final response = await _dataSource.initPayment(request);
      return Right(response);
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
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final response = await _dataSource.verifyPayment(transactionId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      log('error verify $e');
      return Left(ServerFailure(message: 'Une erreur inattendue est survenue'));
    }
  }

  @override
  Future<Either<Failure, MobilePaymentVerifyResponse>> stripeVerifyPayment(
      String transactionId) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final response = await _dataSource.stripeVerifyPayment(transactionId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      log('error verify $e');
      return Left(ServerFailure(message: 'Une erreur inattendue est survenue'));
    }
  }
}
