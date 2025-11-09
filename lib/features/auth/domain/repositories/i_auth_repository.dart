import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';

/// Interface du repository d'authentification
/// Définit le contrat pour les opérations d'authentification
abstract class IAuthRepository {
  /// Vérifie le code du terminal et demande l'envoi d'un OTP
  /// Retourne Either<Failure, AuthResponseModel>
  Future<Either<Failure, AuthResponseModel>> verifyCode(String code);

  /// Vérifie l'OTP et retourne le token d'authentification
  /// Retourne Either<Failure, AuthResponseModel>
  Future<Either<Failure, AuthResponseModel>> verifyOtp(String otp, String code);

  /// Connexion avec email et mot de passe
  /// Retourne Either<Failure, AuthResponseModel>
  Future<Either<Failure, AuthResponseModel>> loginWithEmail(
      String email, String password);
}
