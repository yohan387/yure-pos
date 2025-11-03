import 'package:todouapp/core/mock/mock_data.dart';
import 'package:todouapp/core/mock/mock_helpers.dart';
import 'package:todouapp/features/profil/data/datasources/i_profil_data_source.dart';
import 'package:todouapp/features/profil/data/models/profil_model.dart';

class ProfilMockDataSource implements IProfilDataSource {
  @override
  Future<ProfilModel> getProfil() async {
    await MockHelpers.simulateNetworkDelay();
    return ProfilModel.fromJson(MockData.mockProfil);
  }
}
