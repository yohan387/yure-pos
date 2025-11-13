import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:todouapp/core/constants/api_constants.dart';
import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/utils/token_validator.dart';
import 'package:todouapp/core/utils/secure_storage.dart';

import '../utils/event_bus.dart';

class ApiClient {
  final http.Client client;
  final String baseUrl;
  final SecureStorageService secureStorage;

  ApiClient({
    required this.client,
    required this.secureStorage,
    this.baseUrl = ApiConstants.baseUrl,
  });

  Future<dynamic> authenticatedRequest(Function request) async {
    final token = await secureStorage.getToken();
    log("obtenir le token $token");

    // Vérifier la validité du token
    if (!TokenValidator.isTokenValid(token)) {
      await secureStorage.deleteToken();
      eventBus.fire(TokenExpiredEvent());
      throw ServerException(
          message: 'La session a expiré. Veuillez vous reconnecter.');
    }

    return await request();
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = {...ApiConstants.headers, ...?headers};

    if (requiresAuth) {
      return authenticatedRequest(() async {
        final token = await secureStorage.getToken();

        final authHeaders = {
          ...mergedHeaders,
          'Authorization': 'Bearer $token',
        };

        log(uri.toString());
        final response = await client
            .post(
              uri,
              body: jsonEncode(body),
              headers: authHeaders,
            )
            .timeout(ApiConstants.receiveTimeout);

        return _handleResponse(response);
      });
    } else {
      // Pour les endpoints non authentifiés (comme le login)
      try {
        log(uri.toString());
        final response = await client
            .post(
              uri,
              body: jsonEncode(body),
              headers: mergedHeaders,
            )
            .timeout(ApiConstants.receiveTimeout);

        return _handleResponse(response);
      } catch (e) {
        throw ServerException(message: '$e');
      }
    }
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = {...ApiConstants.headers, ...?headers};

    if (requiresAuth) {
      return authenticatedRequest(() async {
        final token = await secureStorage.getToken();
        final authHeaders = {
          ...mergedHeaders,
          'Authorization': 'Bearer $token',
        };

        final response = await client
            .get(
              uri,
              headers: authHeaders,
            )
            .timeout(ApiConstants.receiveTimeout);

        return _handleResponse(response);
      });
    } else {
      try {
        final response = await client
            .get(
              uri,
              headers: mergedHeaders,
            )
            .timeout(ApiConstants.receiveTimeout);

        return _handleResponse(response);
      } catch (e) {
        throw ServerException(message: '$e');
      }
    }
  }

  dynamic _handleResponse(http.Response response) {
    final responseJson = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseJson;
    } else if (response.statusCode == 401) {
      // Si le serveur retourne 401, déclencher la déconnexion
      // secureStorage.deleteToken();
      // eventBus.fire(TokenExpiredEvent());
      // throw ServerException(
      //   message: 'Session expired. Please log in again.',
      //   statusCode: response.statusCode,
      // );
    } else {
      log('handle res ${responseJson}');
      throw ServerException(
        message: responseJson['detail'] ?? 'Unknown error occurred',
        statusCode: response.statusCode,
      );
    }
  }
}
