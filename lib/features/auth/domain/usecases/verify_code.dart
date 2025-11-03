import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';

/// UseCase pour vérifier le code terminal et demander l'envoi d'un OTP
class VerifyCode {
  final IAuthRepository _repository;

  VerifyCode(IAuthRepository repository) : _repository = repository;

  Future<Either<Failure, AuthResponseModel>> call(String code) async {
    return await _repository.verifyCode(code);
  }
}
