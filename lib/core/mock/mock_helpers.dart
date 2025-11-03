import 'dart:math';
import 'package:todouapp/core/errors/exceptions.dart';

/// Helpers pour simuler des comportements réseaux en mode mock
class MockHelpers {
  static final Random _random = Random();

  /// Simule une latence réseau réaliste
  ///
  /// [minMs] - délai minimum en millisecondes (défaut: 500ms)
  /// [maxMs] - délai maximum en millisecondes (défaut: 1500ms)
  static Future<void> simulateNetworkDelay({
    int minMs = 500,
    int maxMs = 1500,
  }) async {
    final delay = minMs + _random.nextInt(maxMs - minMs);
    await Future.delayed(Duration(milliseconds: delay));
  }

  /// Simule une erreur aléatoire avec une probabilité donnée
  ///
  /// [errorRate] - probabilité d'erreur entre 0.0 et 1.0 (défaut: 0.1 = 10%)
  /// [message] - message d'erreur personnalisé
  static void simulateRandomError({
    double errorRate = 0.1,
    String message = "Erreur réseau simulée",
  }) {
    if (_random.nextDouble() < errorRate) {
      throw ServerException(message: message);
    }
  }

  /// Simule un délai progressif (utile pour les vérifications de paiement)
  ///
  /// [attemptNumber] - numéro de la tentative (plus il est élevé, plus le délai est long)
  /// [baseDelayMs] - délai de base en millisecondes (défaut: 2000ms)
  static Future<void> simulateVerificationDelay({
    required int attemptNumber,
    int baseDelayMs = 2000,
  }) async {
    final delay = baseDelayMs + (attemptNumber * 500);
    await Future.delayed(Duration(milliseconds: delay));
  }

  /// Génère un ID de transaction mocké
  static String generateMockTransactionId() {
    return "mock_txn_${DateTime.now().millisecondsSinceEpoch}";
  }

  /// Génère un code QR mocké pour un méthode de paiement donnée
  static String generateMockQrCode(String method) {
    return "MOCK_${method.toUpperCase()}_QR_${DateTime.now().millisecondsSinceEpoch}";
  }

  /// Génère un Payment Intent ID mocké (Stripe)
  static String generateMockPaymentIntent() {
    return "pi_mock_${DateTime.now().millisecondsSinceEpoch}";
  }

  /// Génère un Client Secret mocké (Stripe)
  static String generateMockClientSecret() {
    return "pi_mock_secret_${DateTime.now().millisecondsSinceEpoch}";
  }
}
