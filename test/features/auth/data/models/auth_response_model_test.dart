import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';

import '../../../../fixtures/fixtures_reader.dart';

void main() {
  final tAuthResponseModel = AuthResponseModel(
    message: 'OTP verified successfully',
    accessToken:
        'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik80aUNHSnpaUDc3YXd5QmoyN3lIYVZUdHpuRjlxN2pLQ0R5MDBNNDZZ3lMGRzIn0.eyJleHAiOjE3NDE3MDkzNTgsImlhdCI6MTczOTA3MjU1OCwianRpIjoiZGIzMWE0ODktZjY3OS00YjQ5LWFlMWItNTQ2NzAyYTRiMGQyIiwiaXNzIjoiaHR0cHM6Ly9hdXRoLXN0YWdpbmcudG9kb3VzdHVkaW8uY2xvdWQvcmVhbG1zL3R5dXJlLWRldiIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiI0MTRhNjcxZC02NDQ2LTRiMmQtYWI4Yi00NzU2MzY0YWE0Y2EiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJ0eXVyZS1mcm9udGVuZCIsImFjciI6IjEiLCJhbGxvd2VkLW9yaWdpbnMiOlsiLyoiXSwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbIm9mZmxpbmVfYWNjZXNzIiwidW1hX2F1dGhvcml6YXRpb24iLCJkZWZhdWx0LXJvbGVzLXR5dXJlLWRldiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImVtYWlsX3ZlcmlmaWVkIjpmYWxzZSwibmFtZSI6IkpvaG4gRG9lIiwicHJlZmVycmVkX3VzZXJuYW1lIjoiam9obi5kb2UiLCJnaXZlbl9uYW1lIjoiSm9obiIsImZhbWlseV9uYW1lIjoiRG9lIiwiZW1haWwiOiJqb2huLmRvZUBleGFtcGxlLmNvbSJ9.signature',
    marchandId: 'merchant_123456',
    terminalId: 'terminal_789',
    merchantFirstName: 'John',
  );

  group('AuthResponseModel', () {
    test('should be properly instantiated with all fields', () {
      expect(tAuthResponseModel.message, 'OTP verified successfully');
      expect(tAuthResponseModel.accessToken, isNotEmpty);
      expect(tAuthResponseModel.marchandId, 'merchant_123456');
      expect(tAuthResponseModel.terminalId, 'terminal_789');
      expect(tAuthResponseModel.merchantFirstName, 'John');
    });

    group('fromJson', () {
      test('should return a valid model from JSON', () {
        // Arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('auth_response.json'));

        // Act
        final result = AuthResponseModel.fromJson(jsonMap);

        // Assert
        expect(result, isA<AuthResponseModel>());
        expect(result.message, 'OTP verified successfully');
        expect(result.accessToken, isNotEmpty);
        expect(result.marchandId, 'merchant_123456');
        expect(result.terminalId, 'terminal_789');
        expect(result.merchantFirstName, 'John');
      });

      test('should handle missing merchantFirstName (converts null to "null")', () {
        // Arrange
        final jsonMap = {
          'message': 'Success',
          'access_token': 'token123',
          'merchant_id': 'merchant_1',
          'terminal_id': 'terminal_1',
        };

        // Act
        final result = AuthResponseModel.fromJson(jsonMap);

        // Assert
        // Model uses "${json['merchant_first_name']}" which converts null to "null"
        expect(result.merchantFirstName, 'null');
      });

      test('should handle all fields present', () {
        // Arrange
        final jsonMap = {
          'message': 'Login successful',
          'access_token': 'jwt_token_here',
          'merchant_id': 'merchant_abc',
          'terminal_id': 'terminal_xyz',
          'merchant_first_name': 'Jane',
        };

        // Act
        final result = AuthResponseModel.fromJson(jsonMap);

        // Assert
        expect(result.message, 'Login successful');
        expect(result.accessToken, 'jwt_token_here');
        expect(result.marchandId, 'merchant_abc');
        expect(result.terminalId, 'terminal_xyz');
        expect(result.merchantFirstName, 'Jane');
      });
    });
  });
}
