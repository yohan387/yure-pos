import 'dart:developer';

import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/network/api_client.dart';
import 'package:todouapp/features/profil/data/datasources/i_profil_data_source.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/secure_storage.dart';
import '../models/profil_model.dart';

/// Implémentation Remote de IProfilDataSource
class ProfilRemoteDataSource implements IProfilDataSource {
  final ApiClient _apiClient;

  ProfilRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ProfilModel> getProfil() async {
    try {
      log('Profile loading...');
      final secureStorage = SecureStorageService();
      final marchantId = await secureStorage.getMarchandId();
      final response = await _apiClient.get(
          '${ApiConstants.transactionsEndpoint}$marchantId',
          requiresAuth: true);
      return ProfilModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      log('$e');
      throw ServerException(message: 'Failed to fetch profil');
    }
  }
}
