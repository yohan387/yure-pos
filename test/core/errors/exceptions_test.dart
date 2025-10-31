import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/core/errors/exceptions.dart';

void main() {
  group('ServerException', () {
    test('should contain message and statusCode', () {
      const message = 'Server error occurred';
      const statusCode = 500;

      final exception = ServerException(message: message, statusCode: statusCode);

      expect(exception.message, message);
      expect(exception.statusCode, statusCode);
    });

    test('should have meaningful toString', () {
      final exception = ServerException(message: 'Not found', statusCode: 404);

      expect(exception.toString(), equals('Not found'));
      expect(exception.toString(), isNotEmpty);
    });

    test('should support different status codes', () {
      final exception400 = ServerException(message: 'Bad request', statusCode: 400);
      final exception401 = ServerException(message: 'Unauthorized', statusCode: 401);
      final exception403 = ServerException(message: 'Forbidden', statusCode: 403);

      expect(exception400.statusCode, 400);
      expect(exception401.statusCode, 401);
      expect(exception403.statusCode, 403);
    });
  });

  group('CacheException', () {
    test('should contain message', () {
      const message = 'Cache read failed';

      final exception = CacheException(message: message);

      expect(exception.message, message);
    });

    test('should have meaningful toString', () {
      final exception = CacheException(message: 'Data not found in cache');

      expect(exception.toString(), contains('CacheException'));
      expect(exception.toString(), contains('Data not found in cache'));
    });
  });

  group('TokenExpiredException', () {
    test('should contain message', () {
      const message = 'JWT token has expired';

      final exception = TokenExpiredException(message: message);

      expect(exception.message, message);
    });

    test('should have meaningful toString', () {
      final exception = TokenExpiredException(message: 'Session expired');

      expect(exception.toString(), contains('TokenExpiredException'));
      expect(exception.toString(), contains('Session expired'));
    });

    test('should have default message for token expiry', () {
      final exception = TokenExpiredException(message: 'Token expired');

      expect(exception.message, isNotEmpty);
      expect(exception.message, contains('expired'));
    });
  });
}
