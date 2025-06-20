import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthResponseModel>> verifyCode(String code);
  Future<Either<Failure, AuthResponseModel>> verifyOtp(String otp, String code);
}
