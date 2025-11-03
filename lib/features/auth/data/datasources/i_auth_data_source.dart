import 'package:todouapp/features/auth/data/models/auth_response_model.dart';

/// Interface pour les sources de données d'authentification
/// Implémentations: AuthRemoteDataSource (API), AuthMockDataSource (Mock)
abstract interface class IAuthDataSource {
  /// Vérifie le code du terminal et demande l'envoi d'un OTP
  /// Lance ServerException si le code est invalide
  Future<AuthResponseModel> verifyCode(String code);

  /// Vérifie l'OTP et retourne le token d'authentification
  /// Lance ServerException si l'OTP est invalide
  Future<AuthResponseModel> verifyOtp(String otp, String code);
}
