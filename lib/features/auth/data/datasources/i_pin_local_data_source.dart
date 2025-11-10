/// Interface du data source local pour la gestion du PIN
/// Définit les opérations de stockage local du PIN
abstract class IPinLocalDataSource {
  /// Sauvegarde le hash du PIN dans le stockage sécurisé
  Future<void> savePinHash(String pinHash);

  /// Récupère le hash du PIN depuis le stockage sécurisé
  Future<String?> getPinHash();

  /// Supprime le hash du PIN du stockage sécurisé
  Future<void> deletePinHash();

  /// Vérifie si un PIN est configuré
  Future<bool> hasPinConfigured();

  /// Définit si l'utilisateur a ignoré la configuration du PIN
  Future<void> setPinSetupSkipped(bool skipped);

  /// Vérifie si l'utilisateur a ignoré la configuration du PIN
  Future<bool> hasPinSetupSkipped();
}
