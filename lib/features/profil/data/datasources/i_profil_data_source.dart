import '../models/profil_model.dart';

/// Interface pour les sources de données de profil
abstract interface class IProfilDataSource {
  Future<ProfilModel> getProfil();
}
