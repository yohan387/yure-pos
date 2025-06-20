import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';

class VerifyOtp {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  Future<Either<Failure, AuthResponseModel>> call(
      String otp, String code) async {
    return await repository.verifyOtp(otp, code);
  }
}
