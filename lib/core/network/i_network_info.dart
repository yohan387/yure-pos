/// Interface pour vérifier la connectivité réseau
/// Utilisée par les repositories pour vérifier l'état de la connexion avant les appels API
abstract interface class INetworkInfo {
  /// Vérifie si l'appareil est connecté à Internet
  /// Retourne true si connecté, false sinon
  Future<bool> get isConnected;
}
