import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/core/utils/token_validator.dart';

void main() {
  group('TokenValidator', () {
    test('isTokenValid returns true for valid token with future expiry', () {
      // Valid JWT token with exp claim in the future (year 2030)
      // Header: {"alg":"HS256","typ":"JWT"}
      // Payload: {"exp":1893456000,"sub":"test"}
      // Note: This is a mock token for testing purposes
      const validToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJleHAiOjE4OTM0NTYwMDAsInN1YiI6InRlc3QifQ.'
          'signature';

      final result = TokenValidator.isTokenValid(validToken);

      expect(result, isTrue);
    });

    test('isTokenValid returns false for expired token', () {
      // Expired JWT token with exp claim in the past (year 2020)
      // Header: {"alg":"HS256","typ":"JWT"}
      // Payload: {"exp":1577836800,"sub":"test"}
      const expiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJleHAiOjE1Nzc4MzY4MDAsInN1YiI6InRlc3QifQ.'
          'signature';

      final result = TokenValidator.isTokenValid(expiredToken);

      expect(result, isFalse);
    });

    test('isTokenValid returns false for null token', () {
      final result = TokenValidator.isTokenValid(null);

      expect(result, isFalse);
    });

    test('isTokenValid returns false for empty token', () {
      final result = TokenValidator.isTokenValid('');

      expect(result, isFalse);
    });

    test('isTokenValid returns false for malformed token (not 3 parts)', () {
      const malformedToken = 'invalid.token';

      final result = TokenValidator.isTokenValid(malformedToken);

      expect(result, isFalse);
    });

    test('isTokenValid returns false for token with invalid base64 payload', () {
      const invalidBase64Token = 'header.!!!invalid!!!.signature';

      final result = TokenValidator.isTokenValid(invalidBase64Token);

      expect(result, isFalse);
    });

    test('isTokenValid returns false for token without exp claim', () {
      // JWT token without exp claim
      // Header: {"alg":"HS256","typ":"JWT"}
      // Payload: {"sub":"test"}
      const tokenWithoutExp = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJzdWIiOiJ0ZXN0In0.'
          'signature';

      final result = TokenValidator.isTokenValid(tokenWithoutExp);

      expect(result, isFalse);
    });

    test('isTokenValid returns false for token with invalid JSON payload', () {
      // Token with invalid JSON in payload
      const invalidJsonToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'bm90X3ZhbGlkX2pzb24=' // "not_valid_json" in base64
          '.signature';

      final result = TokenValidator.isTokenValid(invalidJsonToken);

      expect(result, isFalse);
    });
  });
}
