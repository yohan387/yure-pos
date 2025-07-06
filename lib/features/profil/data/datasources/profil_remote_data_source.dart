import 'dart:developer';

import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/network/api_client.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/secure_storage.dart';
import '../models/profil_model.dart';

abstract class ProfilRemoteDataSource {
  Future<ProfilModel> getProfil();
}

class ProfilRemoteDataSourceImpl implements ProfilRemoteDataSource {
  final ApiClient apiClient;

  ProfilRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ProfilModel> getProfil() async {
    try {
      log('Profile loading...');
      final secureStorage = SecureStorageService();
      final marchantId = await secureStorage.getMarchandId();
      final response = await apiClient.get(
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
