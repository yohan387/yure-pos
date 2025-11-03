import 'dart:developer';

import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/i_network_info.dart';
import 'package:todouapp/features/auth/data/datasources/i_auth_data_source.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/auth_response_model.dart';

/// Implémentation du repository d'authentification
/// Gère la logique métier et la vérification réseau
class AuthRepositoryImpl implements IAuthRepository {
  final IAuthDataSource _dataSource;
  final INetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required IAuthDataSource dataSource,
    required INetworkInfo networkInfo,
  })  : _dataSource = dataSource,
        _networkInfo = networkInfo;

  @override
  Future<Either<Failure, AuthResponseModel>> verifyCode(String code) async {
    log('Network info ${_networkInfo.isConnected}');
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final response = await _dataSource.verifyCode(code);
      return Right(response);
    } on ServerException catch (e) {
      log('auth impl ${e.message}');
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> verifyOtp(
      String otp, String code) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final response = await _dataSource.verifyOtp(otp, code);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
