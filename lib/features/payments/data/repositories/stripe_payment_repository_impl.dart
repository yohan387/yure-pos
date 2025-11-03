import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/i_network_info.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/i_stripe_payment_repository.dart';
import '../datasources/i_stripe_payment_data_source.dart';
import '../models/stripe_payment_intent_response.dart';

class StripePaymentRepositoryImpl implements IStripePaymentRepository {
  final IStripePaymentDataSource _dataSource;
  final INetworkInfo _networkInfo;

  StripePaymentRepositoryImpl({
    required IStripePaymentDataSource dataSource,
    required INetworkInfo networkInfo,
  })  : _dataSource = dataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, StripePaymentIntentResponse>> createPaymentIntent(
      int amount) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final response = await _dataSource.createPaymentIntent(amount);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      log('error stripe $e');
      return Left(ServerFailure(message: 'Une erreur inattendue est survenue'));
    }
  }

  @override
  Future<Either<Failure, StripeLinkToPayResponse>> createLinkPayment(
      int amount) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final response = await _dataSource.createLinkPayment(amount);
      return Right(response);
    } on ServerException catch (e) {
      log('on payment ${e.message}');
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      log('error payment $e');
      return Left(ServerFailure(message: 'Une erreur inattendue est survenue'));
    }
  }
}
