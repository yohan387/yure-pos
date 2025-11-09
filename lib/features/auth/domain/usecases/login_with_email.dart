import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';

/// Use case pour la connexion avec email et mot de passe
/// Suit le pattern Clean Architecture: UI → Cubit → UseCase → Repository
class LoginWithEmail {
  final IAuthRepository _repository;

  LoginWithEmail(this._repository);

  /// Exécute la connexion avec email et mot de passe
  /// Retourne Either<Failure, AuthResponseModel>
  Future<Either<Failure, AuthResponseModel>> call(
      String email, String password) async {
    return await _repository.loginWithEmail(email, password);
  }
}
