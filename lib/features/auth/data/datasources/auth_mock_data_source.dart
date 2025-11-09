import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/mock/mock_data.dart';
import 'package:todouapp/core/mock/mock_helpers.dart';
import 'package:todouapp/features/auth/data/datasources/i_auth_data_source.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';

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

    if (otp == "1234") {
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
      "test@yure.com": "Test1234",
      "admin@yure.com": "Admin1234",
      "merchant@yure.com": "Merchant123",
    };

    if (!email.contains('@') || !email.contains('.')) {
      throw ServerException(message: "Format email invalide");
    }

    if (password.isEmpty) {
      throw ServerException(message: "Mot de passe requis");
    }

    if (validAccounts.containsKey(email) &&
        validAccounts[email] == password) {
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
}
