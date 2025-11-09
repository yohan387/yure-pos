import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/mock/mock_data.dart';
import 'package:todouapp/core/mock/mock_helpers.dart';
import 'package:todouapp/features/auth/data/datasources/i_auth_data_source.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';
import 'package:todouapp/features/auth/data/models/terminal_model.dart';

class AuthMockDataSource implements IAuthDataSource {
  @override
  Future<AuthResponseModel> verifyCode(String code) async {
    await MockHelpers.simulateNetworkDelay();

    if (code.isNotEmpty) {
      return AuthResponseModel.fromJson({
        "success": true,
        "message": "OTP envoyé au marchand",
        "data": null,
      });
    }

    throw ServerException(message: "Code terminal invalide");
  }

  @override
  Future<AuthResponseModel> verifyOtp(String otp, String code) async {
    await MockHelpers.simulateNetworkDelay();

    if (otp == "234567") {
      return AuthResponseModel.fromJson({
        "success": true,
        "message": "Connexion réussie",
        "data": {
          "token": MockData.mockToken,
          "terminal": {
            "id": "terminal_mock_001",
            "code": code,
            "merchant_name": "Boutique Todou Test",
          },
        },
      });
    }

    throw ServerException(message: "OTP invalide");
  }

  @override
  Future<AuthResponseModel> loginWithEmail(
      String email, String password) async {
    await MockHelpers.simulateNetworkDelay();

    final validAccounts = {
      "test@yure.com": "123456",
      "admin@yure.com": "123456",
      "merchant@yure.com": "123456",
    };

    if (!email.contains('@') || !email.contains('.')) {
      throw ServerException(message: "Format email invalide");
    }

    if (password.isEmpty) {
      throw ServerException(message: "Mot de passe requis");
    }

    if (validAccounts.containsKey(email) && validAccounts[email] == password) {
      return AuthResponseModel.fromJson({
        "success": true,
        "message": "OTP envoyé à votre email",
        "data": {
          "email": email,
          "otp_sent": true,
        },
      });
    }

    throw ServerException(message: "Email ou mot de passe incorrect");
  }

  @override
  Future<AuthResponseModel> resendEmailOtp(String email) async {
    await MockHelpers.simulateNetworkDelay();

    if (!email.contains('@') || !email.contains('.')) {
      throw ServerException(message: "Format email invalide");
    }

    return AuthResponseModel.fromJson({
      "success": true,
      "message": "Code OTP renvoyé avec succès",
      "data": {
        "email": email,
        "otp_sent": true,
      },
    });
  }

  @override
  Future<AuthResponseModel> verifyEmailOtp(String email, String otp) async {
    await MockHelpers.simulateNetworkDelay();

    if (!email.contains('@') || !email.contains('.')) {
      throw ServerException(message: "Format email invalide");
    }

    if (otp.isEmpty || otp.length != 6) {
      throw ServerException(message: "Format OTP invalide");
    }

    if (otp == "234567") {
      return AuthResponseModel.fromJson({
        "success": true,
        "message": "Vérification réussie",
        "data": {
          "token": MockData.mockToken,
          "user": {
            "id": "user_mock_001",
            "email": email,
            "name": "Utilisateur Test",
          },
        },
      });
    }

    throw ServerException(message: "Code OTP invalide ou expiré");
  }

  @override
  Future<List<TerminalModel>> getMerchantTerminals() async {
    await MockHelpers.simulateNetworkDelay();

    // Convertir les données mockées en liste de TerminalModel
    return MockData.mockTerminals
        .map((json) => TerminalModel.fromJson(json))
        .toList();
  }
}
