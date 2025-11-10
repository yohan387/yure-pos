import 'package:todouapp/core/types/future_result.dart';

/// Interface du repository pour la gestion du code PIN
/// Définit les opérations liées au stockage et à la vérification du PIN
abstract class IPinRepository {
  /// Sauvegarde un code PIN (hashé) de manière sécurisée
  FutureResult<void> savePin(String pin);

  /// Vérifie si un code PIN saisi correspond au PIN stocké
  FutureResult<bool> verifyPin(String pin);

  /// Supprime le code PIN stocké
  FutureResult<void> deletePin();

  /// Vérifie si un code PIN est configuré
  FutureResult<bool> hasPinConfigured();

  /// Définit si l'utilisateur a ignoré la configuration du PIN
  FutureResult<void> setPinSetupSkipped(bool skipped);

  /// Vérifie si l'utilisateur a ignoré la configuration du PIN
  FutureResult<bool> hasPinSetupSkipped();
}
