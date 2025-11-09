import 'package:todouapp/features/auth/data/models/auth_response_model.dart';
import 'package:todouapp/features/auth/data/models/terminal_model.dart';

/// Interface pour les sources de données d'authentification
/// Implémentations: AuthRemoteDataSource (API), AuthMockDataSource (Mock)
abstract interface class IAuthDataSource {
  Future<AuthResponseModel> verifyCode(String code);

  Future<AuthResponseModel> verifyOtp(String otp, String code);

  Future<AuthResponseModel> loginWithEmail(String email, String password);

  Future<AuthResponseModel> resendEmailOtp(String email);

  Future<AuthResponseModel> verifyEmailOtp(String email, String otp);

  Future<List<TerminalModel>> getMerchantTerminals();
}
