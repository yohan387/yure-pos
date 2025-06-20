import 'dart:developer';

import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/network_info.dart';
import 'package:todouapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:todouapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.apiClient,
    required this.remoteDataSource,
    required this.networkInfo,
  });

  // @override
  // Future<Either<Failure, AuthResponseModel>> verifyCode(String code) async {
  //   if (!await networkInfo.isConnected) {
  //     return Left(NetworkFailure());
  //   }

  //   try {
  //     final response = await remoteDataSource.verifyCode(code);
  //     return Right(response);
  //   } on ServerException catch (e) {
  //     return Left(ServerFailure(message: e.message));
  //   }
  // }

  @override
  Future<Either<Failure, AuthResponseModel>> verifyCode(String code) async {
    log('Network info ${networkInfo.isConnected}');
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final response = await remoteDataSource.verifyCode(code);
      return Right(response);
    } on ServerException catch (e) {
      log('auth impl ${e.message}');
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AuthResponseModel>> verifyOtp(
      String otp, String code) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final response = await remoteDataSource.verifyOtp(otp, code);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}
