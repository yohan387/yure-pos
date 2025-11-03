import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';

/// UseCase pour vérifier l'OTP et obtenir le token d'authentification
class VerifyOtp {
  final IAuthRepository _repository;

  VerifyOtp(IAuthRepository repository) : _repository = repository;

  Future<Either<Failure, AuthResponseModel>> call(
      String otp, String code) async {
    return await _repository.verifyOtp(otp, code);
  }
}
