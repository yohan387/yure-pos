import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/core/errors/failures.dart';

void main() {
  group('ServerFailure', () {
    test('should contain message', () {
      const message = 'Server connection failed';
      final failure = ServerFailure(message: message);

      expect(failure.message, message);
    });

    test('should be Equatable', () {
      final failure1 = ServerFailure(message: 'Error 1');
      final failure2 = ServerFailure(message: 'Error 1');
      final failure3 = ServerFailure(message: 'Error 2');

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });

    test('should have props for Equatable', () {
      final failure = ServerFailure(message: 'Test error');

      expect(failure.props, [failure.message]);
    });
  });

  group('CacheFailure', () {
    test('should contain message', () {
      const message = 'Cache write failed';
      final failure = CacheFailure(message: message);

      expect(failure.message, message);
    });

    test('should be Equatable', () {
      final failure1 = CacheFailure(message: 'Cache error 1');
      final failure2 = CacheFailure(message: 'Cache error 1');
      final failure3 = CacheFailure(message: 'Cache error 2');

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });
  });

  group('NetworkFailure', () {
    test('should contain default message', () {
      const failure = NetworkFailure();

      expect(failure.message, isNotEmpty);
      expect(failure.message, contains('connexion'));
    });

    test('should be Equatable', () {
      const failure1 = NetworkFailure();
      const failure2 = NetworkFailure();

      expect(failure1, equals(failure2));
    });

    test('should have French error message', () {
      const failure = NetworkFailure();

      expect(failure.message, contains('internet'));
    });
  });

  group('TokenExpiredFailure', () {
    test('should contain default message', () {
      const failure = TokenExpiredFailure();

      expect(failure.message, isNotEmpty);
      expect(failure.message, contains('session'));
    });

    test('should be Equatable', () {
      const failure1 = TokenExpiredFailure();
      const failure2 = TokenExpiredFailure();

      expect(failure1, equals(failure2));
    });

    test('should have English error message', () {
      const failure = TokenExpiredFailure();

      expect(failure.message, contains('expired'));
      expect(failure.message, contains('log in'));
    });
  });

  group('ValidationFailure', () {
    test('should contain message', () {
      const message = 'Invalid input format';
      final failure = ValidationFailure(message: message);

      expect(failure.message, message);
    });

    test('should be Equatable', () {
      final failure1 = ValidationFailure(message: 'Validation error');
      final failure2 = ValidationFailure(message: 'Validation error');
      final failure3 = ValidationFailure(message: 'Different validation error');

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });
  });

  group('Failure inheritance', () {
    test('all Failures should extend Failure base class', () {
      final serverFailure = ServerFailure(message: 'Server error');
      final cacheFailure = CacheFailure(message: 'Cache error');
      const networkFailure = NetworkFailure();
      const tokenExpiredFailure = TokenExpiredFailure();
      final validationFailure = ValidationFailure(message: 'Validation error');

      expect(serverFailure, isA<Failure>());
      expect(cacheFailure, isA<Failure>());
      expect(networkFailure, isA<Failure>());
      expect(tokenExpiredFailure, isA<Failure>());
      expect(validationFailure, isA<Failure>());
    });

    test('different Failure types should not be equal', () {
      final serverFailure = ServerFailure(message: 'Error');
      const networkFailure = NetworkFailure();

      expect(serverFailure, isNot(equals(networkFailure)));
    });
  });
}
