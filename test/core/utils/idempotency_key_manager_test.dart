import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/core/utils/idempotency_key_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:mocktail/mocktail.dart';

class MockUuid extends Mock implements Uuid {}

void main() {
  group('IdempotencyKeyManager', () {
    late IdempotencyKeyManager keyManager;

    setUp(() {
      keyManager = IdempotencyKeyManager();
    });

    test('generateKey should return a non-empty string', () {
      // Act
      final key = keyManager.generateKey();

      // Assert
      expect(key, isNotEmpty);
      expect(key, isA<String>());
    });

    test('generateKey should return a valid UUID v4 format', () {
      // Act
      final key = keyManager.generateKey();

      // Assert - UUID v4 format: xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx
      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );
      expect(key, matches(uuidRegex));
    });

    test('generateKey should return different keys on each call', () {
      // Act
      final key1 = keyManager.generateKey();
      final key2 = keyManager.generateKey();
      final key3 = keyManager.generateKey();

      // Assert
      expect(key1, isNot(equals(key2)));
      expect(key2, isNot(equals(key3)));
      expect(key1, isNot(equals(key3)));
    });

    test('generateKey should work with custom Uuid instance', () {
      // Arrange
      final mockUuid = MockUuid();
      when(() => mockUuid.v4()).thenReturn('test-uuid-123');

      final customKeyManager = IdempotencyKeyManager(uuid: mockUuid);

      // Act
      final key = customKeyManager.generateKey();

      // Assert
      expect(key, equals('test-uuid-123'));
      verify(() => mockUuid.v4()).called(1);
    });

    test('generateKey should be called multiple times without error', () {
      // Act & Assert
      for (int i = 0; i < 100; i++) {
        final key = keyManager.generateKey();
        expect(key, isNotEmpty);
      }
    });
  });
}
