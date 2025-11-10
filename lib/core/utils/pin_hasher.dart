import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Utilitaire pour hasher les codes PIN de manière sécurisée
/// Utilise SHA-256 pour créer un hash du PIN
class PinHasher {
  /// Hash un code PIN en utilisant SHA-256
  ///
  /// Exemple:
  /// ```dart
  /// final hash = PinHasher.hashPin('1234');
  /// // Retourne: "03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4"
  /// ```
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
