import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/mock/mock_data.dart';
import 'package:todouapp/core/mock/mock_helpers.dart';
import 'package:todouapp/features/auth/data/datasources/i_auth_data_source.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';

/// Implémentation Mock de IAuthDataSource
/// Retourne des données fictives sans appels API
/// Utilisée en mode mock pour le développement et les tests
class AuthMockDataSource implements IAuthDataSource {
  @override
  Future<AuthResponseModel> verifyCode(String code) async {
    // Simule une latence réseau réaliste
    await MockHelpers.simulateNetworkDelay();

    // Accepte n'importe quel code non vide
    if (code.isNotEmpty) {
      return AuthResponseModel.fromJson({
        "success": true,
        "message": "OTP envoyé au marchand",
        "data": null,
      });
    }

    // Simule une erreur pour code vide
    throw ServerException(message: "Code terminal invalide");
  }

  @override
  Future<AuthResponseModel> verifyOtp(String otp, String code) async {
    // Simule une latence réseau réaliste
    await MockHelpers.simulateNetworkDelay();

    // OTP valide: 1234
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

    // OTP invalide
    throw ServerException(message: "OTP invalide");
  }

  @override
  Future<AuthResponseModel> loginWithEmail(
      String email, String password) async {
    // Simule une latence réseau réaliste
    await MockHelpers.simulateNetworkDelay();

    // Comptes de test valides
    final validAccounts = {
      "test@yure.com": "Test1234",
      "admin@yure.com": "Admin1234",
      "merchant@yure.com": "Merchant123",
    };

    // Validation basique du format email
    if (!email.contains('@') || !email.contains('.')) {
      throw ServerException(message: "Format email invalide");
    }

    // Vérification mot de passe vide
    if (password.isEmpty) {
      throw ServerException(message: "Mot de passe requis");
    }

    // Vérification des identifiants
    if (validAccounts.containsKey(email) &&
        validAccounts[email] == password) {
      // Succès: l'OTP sera envoyé automatiquement par le backend
      return AuthResponseModel.fromJson({
        "success": true,
        "message": "OTP envoyé à votre email",
        "data": {
          "email": email,
          "otp_sent": true,
        },
      });
    }

    // Identifiants invalides
    throw ServerException(message: "Email ou mot de passe incorrect");
  }
}
