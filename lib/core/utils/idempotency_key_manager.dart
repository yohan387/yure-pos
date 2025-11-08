import 'package:uuid/uuid.dart';

/// Service de gestion des clés d'idempotence pour éviter les transactions dupliquées.
///
/// Génère des clés UUID v4 uniques qui sont envoyées dans le header X-Idempotency-Key
/// lors des appels API de paiement. Le backend peut ainsi détecter et rejeter les
/// requêtes dupliquées (clics multiples, retry réseau, etc.).
class IdempotencyKeyManager {
  final Uuid _uuid;

  IdempotencyKeyManager({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Génère une nouvelle clé d'idempotence unique (UUID v4).
  ///
  /// Cette clé doit être :
  /// - Générée UNE SEULE fois par intention de paiement utilisateur
  /// - Réutilisée en cas de retry après erreur réseau
  /// - Stockée temporairement par le BLoC jusqu'à succès ou échec définitif
  ///
  /// Example:
  /// ```dart
  /// final key = idempotencyKeyManager.generateKey();
  /// // → "550e8400-e29b-41d4-a716-446655440000"
  /// ```
  String generateKey() {
    return _uuid.v4();
  }
}
