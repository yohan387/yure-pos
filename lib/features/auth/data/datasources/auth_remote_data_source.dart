import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/network/api_client.dart';
import 'package:todouapp/features/auth/data/datasources/i_auth_data_source.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';

import '../../../../core/constants/api_constants.dart';

/// Implémentation Remote de IAuthDataSource
/// Communique avec l'API backend pour l'authentification
class AuthRemoteDataSource implements IAuthDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AuthResponseModel> verifyCode(String code) async {
    try {
      log(code);
      // REMY-IT-POS-B31B5A87
      final response = await _apiClient.post(ApiConstants.loginEndpoint,
          body: {'terminal_code': code}, requiresAuth: false);
      final storage = FlutterSecureStorage();

      await storage.write(key: 'code', value: code);
      log("Response du serveur verify code : ${response.toString()}");
      return AuthResponseModel.fromJson(response);
    } on ServerException {
      log("ERR du serveur verify code");

      rethrow;
    } catch (e) {
      log("ERR du serveur verify code ${e.toString()}");

      throw ServerException(message: 'Failed to verify code');
    }
  }

  @override
  Future<AuthResponseModel> verifyOtp(String otp, code) async {
    try {
      final response = await _apiClient.post(ApiConstants.verifyOtpEndpoint,
          body: {'otp_code': otp, 'terminal_code': code}, requiresAuth: false);
      log("Response du serveur verify otp : ${response.toString()}");

      return AuthResponseModel.fromJson(response);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to verify OTP');
    }
  }

  @override
  Future<AuthResponseModel> loginWithEmail(
      String email, String password) async {
    try {
      final response = await _apiClient.post(ApiConstants.emailLoginEndpoint,
          body: {'email': email, 'password': password}, requiresAuth: false);

      final storage = FlutterSecureStorage();
      await storage.write(key: 'email', value: email);

      log("Response du serveur login email : ${response.toString()}");
      return AuthResponseModel.fromJson(response);
    } on ServerException {
      log("ERR du serveur login email");
      rethrow;
    } catch (e) {
      log("ERR du serveur login email ${e.toString()}");
      throw ServerException(message: 'Failed to login with email');
    }
  }
}
