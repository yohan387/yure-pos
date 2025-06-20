import 'package:dio/dio.dart';
import 'package:todouapp/core/utils/token_validator.dart';
import 'package:todouapp/core/errors/exceptions.dart';

import '../utils/secure_storage.dart';

class ApiInterceptor extends Interceptor {
  final SecureStorageService secureStorage;

  ApiInterceptor({required this.secureStorage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await secureStorage.getToken();
      TokenValidator.isTokenValid(token);
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    } on TokenExpiredException {
      handler.reject(DioException(
        requestOptions: options,
        error: 'Token expired',
        type: DioExceptionType.unknown,
      ));
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 || err.error == 'Token expired') {
      await secureStorage.deleteToken();
      // Émettre un événement global de déconnexion
    }
    handler.next(err);
  }
}
