import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/constants/api_constants.dart';
import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/network/api_client.dart';
import 'package:todouapp/core/utils/secure_storage.dart';

// Mocks
class MockClient extends Mock implements http.Client {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

// Fake URI for fallback value
class FakeUri extends Fake implements Uri {}

void main() {
  late ApiClient apiClient;
  late MockClient mockClient;
  late MockSecureStorageService mockSecureStorage;

  const testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiZXhwIjo5OTk5OTk5OTk5fQ.Ks3SjlZHwPI7P2kGDhJRJLyV_6c-lFMO_jZnSg-YlKU';
  const testEndpoint = '/test-endpoint';
  const testBody = {'key': 'value'};
  const testResponse = {'status': 'success', 'data': 'test data'};

  setUpAll(() {
    // Register fallback values for any() matchers
    registerFallbackValue(FakeUri());
    registerFallbackValue(<String, String>{});
  });

  setUp(() {
    mockClient = MockClient();
    mockSecureStorage = MockSecureStorageService();
    apiClient = ApiClient(
      client: mockClient,
      secureStorage: mockSecureStorage,
    );
  });

  group('ApiClient - GET Requests', () {
    test('should perform authenticated GET request with token from secure storage', () async {
      // Arrange
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => testToken);
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(testResponse),
            200,
          ));

      // Act
      final result = await apiClient.get(testEndpoint);

      // Assert
      expect(result, testResponse);
      // getToken is called twice: once in authenticatedRequest, once in get method
      verify(() => mockSecureStorage.getToken()).called(2);
      verify(() => mockClient.get(
            Uri.parse('${ApiConstants.baseUrl}$testEndpoint'),
            headers: {
              ...ApiConstants.headers,
              'Authorization': 'Bearer $testToken',
            },
          )).called(1);
    });

    test('should perform GET request without authentication when requiresAuth is false', () async {
      // Arrange
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(testResponse),
            200,
          ));

      // Act
      final result = await apiClient.get(testEndpoint, requiresAuth: false);

      // Assert
      expect(result, testResponse);
      verifyNever(() => mockSecureStorage.getToken());
      verify(() => mockClient.get(
            Uri.parse('${ApiConstants.baseUrl}$testEndpoint'),
            headers: ApiConstants.headers,
          )).called(1);
    });

    test('should inject Authorization header with Bearer token for authenticated GET', () async {
      // Arrange
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => testToken);
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(testResponse),
            200,
          ));

      // Act
      await apiClient.get(testEndpoint);

      // Assert
      final captured = verify(() => mockClient.get(
            any(),
            headers: captureAny(named: 'headers'),
          )).captured;
      final headers = captured.first as Map<String, String>;
      expect(headers['Authorization'], 'Bearer $testToken');
      expect(headers['Content-Type'], 'application/json');
      expect(headers['Accept'], 'application/json');
    });

    test('should throw ServerException when GET request fails with network error', () async {
      // Arrange
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => apiClient.get(testEndpoint, requiresAuth: false),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('ApiClient - POST Requests', () {
    test('should perform authenticated POST request with JSON body', () async {
      // Arrange
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => testToken);
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(testResponse),
            200,
          ));

      // Act
      final result = await apiClient.post(testEndpoint, body: testBody);

      // Assert
      expect(result, testResponse);
      // getToken is called twice: once in authenticatedRequest, once in post method
      verify(() => mockSecureStorage.getToken()).called(2);
      verify(() => mockClient.post(
            Uri.parse('${ApiConstants.baseUrl}$testEndpoint'),
            headers: {
              ...ApiConstants.headers,
              'Authorization': 'Bearer $testToken',
            },
            body: jsonEncode(testBody),
          )).called(1);
    });

    test('should perform POST request without authentication when requiresAuth is false', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(testResponse),
            200,
          ));

      // Act
      final result = await apiClient.post(testEndpoint, body: testBody, requiresAuth: false);

      // Assert
      expect(result, testResponse);
      verifyNever(() => mockSecureStorage.getToken());
      verify(() => mockClient.post(
            Uri.parse('${ApiConstants.baseUrl}$testEndpoint'),
            headers: ApiConstants.headers,
            body: jsonEncode(testBody),
          )).called(1);
    });

    test('should encode body as JSON for POST requests', () async {
      // Arrange
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => testToken);
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(testResponse),
            200,
          ));

      // Act
      await apiClient.post(testEndpoint, body: testBody);

      // Assert
      final captured = verify(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          )).captured;
      expect(captured.first, jsonEncode(testBody));
    });

    test('should throw ServerException when POST request fails with network error', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => apiClient.post(testEndpoint, body: testBody, requiresAuth: false),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('ApiClient - Token Management', () {
    test('should throw ServerException when token is expired', () async {
      // Arrange - Token expiré (exp dans le passé)
      const expiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiZXhwIjoxfQ.bXh8TLwJr0kc5wLuKbJvJZkcIBj1cLGtFBzVhDT7nO8';
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => expiredToken);
      when(() => mockSecureStorage.deleteToken()).thenAnswer((_) async => {});

      // Mock client.get même si non appelé (au cas où le token passe)
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('{"error": "Unauthorized"}', 401));

      // Act & Assert
      try {
        await apiClient.get(testEndpoint);
        fail('Should throw ServerException');
      } catch (e) {
        expect(e, isA<ServerException>());
        expect((e as ServerException).message, contains('session a expiré'));
      }

      // Verify que deleteToken a été appelé
      verify(() => mockSecureStorage.deleteToken()).called(1);
    });

    test('should throw ServerException when token is null', () async {
      // Arrange
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => null);
      when(() => mockSecureStorage.deleteToken()).thenAnswer((_) async => {});

      // Mock client.get même si non appelé
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('{"error": "Unauthorized"}', 401));

      // Act & Assert
      try {
        await apiClient.get(testEndpoint);
        fail('Should throw ServerException');
      } catch (e) {
        expect(e, isA<ServerException>());
      }
    });

    test('should throw ServerException when token is empty', () async {
      // Arrange
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => '');
      when(() => mockSecureStorage.deleteToken()).thenAnswer((_) async => {});

      // Mock client.get même si non appelé
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('{"error": "Unauthorized"}', 401));

      // Act & Assert
      try {
        await apiClient.get(testEndpoint);
        fail('Should throw ServerException');
      } catch (e) {
        expect(e, isA<ServerException>());
      }
    });

    test('should throw ServerException when token has invalid format', () async {
      // Arrange
      const invalidToken = 'invalid.token';
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => invalidToken);
      when(() => mockSecureStorage.deleteToken()).thenAnswer((_) async => {});

      // Mock client.get même si non appelé
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('{"error": "Unauthorized"}', 401));

      // Act & Assert
      try {
        await apiClient.get(testEndpoint);
        fail('Should throw ServerException');
      } catch (e) {
        expect(e, isA<ServerException>());
      }
    });
  });

  group('ApiClient - Response Handling', () {
    test('should return parsed JSON for successful response (200)', () async {
      // Arrange
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(testResponse),
            200,
          ));

      // Act
      final result = await apiClient.get(testEndpoint, requiresAuth: false);

      // Assert
      expect(result, testResponse);
    });

    test('should return parsed JSON for successful response (201)', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(testResponse),
            201,
          ));

      // Act
      final result = await apiClient.post(testEndpoint, body: testBody, requiresAuth: false);

      // Assert
      expect(result, testResponse);
    });

    test('should throw ServerException for 403 Forbidden', () async {
      // Arrange
      const errorResponse = {'detail': 'Access forbidden'};
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => testToken);
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            403,
          ));

      // Act & Assert - Using authenticated request to preserve statusCode
      expect(
        () => apiClient.get(testEndpoint),
        throwsA(
          isA<ServerException>()
              .having((e) => e.message, 'message', 'Access forbidden')
              .having((e) => e.statusCode, 'statusCode', 403),
        ),
      );
    });

    test('should throw ServerException for 500 Server Error', () async {
      // Arrange
      const errorResponse = {'detail': 'Internal server error'};
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => testToken);
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            500,
          ));

      // Act & Assert - Using authenticated request to preserve statusCode
      expect(
        () => apiClient.get(testEndpoint),
        throwsA(
          isA<ServerException>()
              .having((e) => e.message, 'message', 'Internal server error')
              .having((e) => e.statusCode, 'statusCode', 500),
        ),
      );
    });

    test('should throw ServerException with generic message when detail is missing', () async {
      // Arrange
      const errorResponse = {'error': 'Something went wrong'};
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => testToken);
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            400,
          ));

      // Act & Assert - Using authenticated request to preserve statusCode
      expect(
        () => apiClient.get(testEndpoint),
        throwsA(
          isA<ServerException>()
              .having((e) => e.message, 'message', 'Unknown error occurred')
              .having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });

    test('should handle 401 Unauthorized gracefully (currently no-op)', () async {
      // Arrange
      const errorResponse = {'detail': 'Unauthorized'};
      when(() => mockSecureStorage.getToken()).thenAnswer((_) async => testToken);
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(errorResponse),
            401,
          ));

      // Act
      final result = await apiClient.get(testEndpoint);

      // Assert - 401 est actuellement ignoré dans le code (bloc commenté) donc retourne null
      expect(result, isNull);
    });
  });

  group('ApiClient - Custom Headers', () {
    test('should merge custom headers with default headers for GET', () async {
      // Arrange
      const customHeaders = {'X-Custom-Header': 'custom-value'};
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(testResponse),
            200,
          ));

      // Act
      await apiClient.get(testEndpoint, headers: customHeaders, requiresAuth: false);

      // Assert
      final captured = verify(() => mockClient.get(
            any(),
            headers: captureAny(named: 'headers'),
          )).captured;
      final headers = captured.first as Map<String, String>;
      expect(headers['X-Custom-Header'], 'custom-value');
      expect(headers['Content-Type'], 'application/json');
      expect(headers['Accept'], 'application/json');
    });

    test('should merge custom headers with default headers for POST', () async {
      // Arrange
      const customHeaders = {'X-Request-Id': '12345'};
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(testResponse),
            200,
          ));

      // Act
      await apiClient.post(
        testEndpoint,
        body: testBody,
        headers: customHeaders,
        requiresAuth: false,
      );

      // Assert
      final captured = verify(() => mockClient.post(
            any(),
            headers: captureAny(named: 'headers'),
            body: any(named: 'body'),
          )).captured;
      final headers = captured.first as Map<String, String>;
      expect(headers['X-Request-Id'], '12345');
      expect(headers['Content-Type'], 'application/json');
      expect(headers['Accept'], 'application/json');
    });
  });

  group('ApiClient - Base URL', () {
    test('should use default base URL from ApiConstants', () async {
      // Arrange
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(testResponse),
            200,
          ));

      // Act
      await apiClient.get(testEndpoint, requiresAuth: false);

      // Assert
      final captured = verify(() => mockClient.get(
            captureAny(),
            headers: any(named: 'headers'),
          )).captured;
      final uri = captured.first as Uri;
      expect(uri.toString(), startsWith(ApiConstants.baseUrl));
    });

    test('should use custom base URL when provided', () async {
      // Arrange
      const customBaseUrl = 'https://custom-api.example.com/api';
      final customApiClient = ApiClient(
        client: mockClient,
        secureStorage: mockSecureStorage,
        baseUrl: customBaseUrl,
      );
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(testResponse),
            200,
          ));

      // Act
      await customApiClient.get(testEndpoint, requiresAuth: false);

      // Assert
      final captured = verify(() => mockClient.get(
            captureAny(),
            headers: any(named: 'headers'),
          )).captured;
      final uri = captured.first as Uri;
      expect(uri.toString(), '$customBaseUrl$testEndpoint');
    });
  });
}
