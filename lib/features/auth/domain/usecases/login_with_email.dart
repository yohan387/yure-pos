import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';

class LoginWithEmail {
  final IAuthRepository _repository;

  LoginWithEmail(this._repository);

  Future<Either<Failure, AuthResponseModel>> call(
      String email, String password) async {
    return await _repository.loginWithEmail(email, password);
  }
}
