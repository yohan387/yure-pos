import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:todouapp/features/profil/data/models/profil_model.dart';

import '../../../../fixtures/fixtures_reader.dart';

void main() {
  final tProfilModel = ProfilModel(
    id: 123456,
    businessType: 'retail',
    businessName: 'Boutique Example',
    stripeAccountId: 'acct_1234567890',
    createdAt: DateTime.parse('2023-01-10T08:00:00Z'),
    updatedAt: DateTime.parse('2024-01-15T12:00:00Z'),
    ownerId: 'owner_abc123',
    username: 'john.doe',
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@example.com',
    emailVerified: true,
    phoneNumbers: ['+221771234567'],
    createdTimestamp: 1673337600000,
    enabled: true,
    totp: false,
    disableableCredentialTypes: [],
    requiredActions: [],
    notBefore: 0,
  );

  group('ProfilModel', () {
    test('should be properly instantiated with all required fields', () {
      expect(tProfilModel.id, 123456);
      expect(tProfilModel.businessType, 'retail');
      expect(tProfilModel.businessName, 'Boutique Example');
      expect(tProfilModel.stripeAccountId, 'acct_1234567890');
      expect(tProfilModel.createdAt, DateTime.parse('2023-01-10T08:00:00Z'));
      expect(tProfilModel.updatedAt, DateTime.parse('2024-01-15T12:00:00Z'));
      expect(tProfilModel.ownerId, 'owner_abc123');
      expect(tProfilModel.username, 'john.doe');
      expect(tProfilModel.firstName, 'John');
      expect(tProfilModel.lastName, 'Doe');
      expect(tProfilModel.email, 'john.doe@example.com');
      expect(tProfilModel.emailVerified, true);
      expect(tProfilModel.phoneNumbers, ['+221771234567']);
      expect(tProfilModel.createdTimestamp, 1673337600000);
      expect(tProfilModel.enabled, true);
      expect(tProfilModel.totp, false);
      expect(tProfilModel.disableableCredentialTypes, []);
      expect(tProfilModel.requiredActions, []);
      expect(tProfilModel.notBefore, 0);
    });

    test('should allow null stripeAccountId', () {
      final model = ProfilModel(
        id: 1,
        businessType: 'retail',
        businessName: 'Test',
        stripeAccountId: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerId: 'owner123',
        username: 'test',
        firstName: 'Test',
        lastName: 'User',
        email: 'test@example.com',
        emailVerified: false,
        phoneNumbers: [],
        createdTimestamp: 0,
        enabled: true,
        totp: false,
        disableableCredentialTypes: [],
        requiredActions: [],
        notBefore: 0,
      );

      expect(model.stripeAccountId, isNull);
    });

    group('fromJson', () {
      test('should return a valid model from JSON fixture', () {
        // Arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('profil_response.json'));

        // Act
        final result = ProfilModel.fromJson(jsonMap);

        // Assert
        expect(result, isA<ProfilModel>());
        expect(result.id, 123456);
        expect(result.businessType, 'retail');
        expect(result.businessName, 'Boutique Example');
        expect(result.stripeAccountId, 'acct_1234567890');
        expect(result.createdAt, DateTime.parse('2023-01-10T08:00:00Z'));
        expect(result.updatedAt, DateTime.parse('2024-01-15T12:00:00Z'));
        expect(result.ownerId, 'owner_abc123');
        expect(result.username, 'john.doe');
        expect(result.firstName, 'John');
        expect(result.lastName, 'Doe');
        expect(result.email, 'john.doe@example.com');
        expect(result.emailVerified, true);
        expect(result.phoneNumbers, ['+221771234567']);
        expect(result.createdTimestamp, 1673337600000);
        expect(result.enabled, true);
        expect(result.totp, false);
        expect(result.disableableCredentialTypes, []);
        expect(result.requiredActions, []);
        expect(result.notBefore, 0);
      });

      test('should handle null stripeAccountId in JSON', () {
        // Arrange
        final jsonMap = {
          'id': 789,
          'business_type': 'service',
          'business_name': 'Test Business',
          'stripe_account_id': null,
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-02T00:00:00Z',
          'owner': {
            'id': 'owner_xyz',
            'username': 'testuser',
            'firstName': 'Test',
            'lastName': 'User',
            'email': 'test@test.com',
            'emailVerified': false,
            'attributes': {
              'phoneNumber': ['+221770000000'],
            },
            'createdTimestamp': 1704067200000,
            'enabled': true,
            'totp': true,
            'disableableCredentialTypes': ['password'],
            'requiredActions': ['UPDATE_PASSWORD'],
            'notBefore': 0,
          },
        };

        // Act
        final result = ProfilModel.fromJson(jsonMap);

        // Assert
        expect(result.stripeAccountId, isNull);
        expect(result.businessName, 'Test Business');
      });

      test('should parse owner nested object correctly', () {
        // Arrange
        final jsonMap = {
          'id': 1,
          'business_type': 'test',
          'business_name': 'Test',
          'stripe_account_id': 'acct_test',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
          'owner': {
            'id': 'owner_test',
            'username': 'testuser',
            'firstName': 'John',
            'lastName': 'Smith',
            'email': 'john@test.com',
            'emailVerified': true,
            'attributes': {
              'phoneNumber': ['+221771111111', '+221772222222'],
            },
            'createdTimestamp': 1000000,
            'enabled': false,
            'totp': true,
            'disableableCredentialTypes': ['otp'],
            'requiredActions': ['VERIFY_EMAIL'],
            'notBefore': 100,
          },
        };

        // Act
        final result = ProfilModel.fromJson(jsonMap);

        // Assert
        expect(result.ownerId, 'owner_test');
        expect(result.username, 'testuser');
        expect(result.firstName, 'John');
        expect(result.lastName, 'Smith');
        expect(result.email, 'john@test.com');
        expect(result.emailVerified, true);
        expect(result.phoneNumbers, ['+221771111111', '+221772222222']);
        expect(result.createdTimestamp, 1000000);
        expect(result.enabled, false);
        expect(result.totp, true);
        expect(result.disableableCredentialTypes, ['otp']);
        expect(result.requiredActions, ['VERIFY_EMAIL']);
        expect(result.notBefore, 100);
      });

      test('should handle empty lists in owner attributes', () {
        // Arrange
        final jsonMap = {
          'id': 1,
          'business_type': 'test',
          'business_name': 'Test',
          'created_at': '2024-01-01T00:00:00Z',
          'updated_at': '2024-01-01T00:00:00Z',
          'owner': {
            'id': 'owner1',
            'username': 'user1',
            'firstName': 'First',
            'lastName': 'Last',
            'email': 'email@test.com',
            'emailVerified': false,
            'attributes': {
              'phoneNumber': [],
            },
            'createdTimestamp': 0,
            'enabled': true,
            'totp': false,
            'disableableCredentialTypes': [],
            'requiredActions': [],
            'notBefore': 0,
          },
        };

        // Act
        final result = ProfilModel.fromJson(jsonMap);

        // Assert
        expect(result.phoneNumbers, isEmpty);
        expect(result.disableableCredentialTypes, isEmpty);
        expect(result.requiredActions, isEmpty);
      });
    });

    group('toJson', () {
      test('should convert model to valid JSON', () {
        // Act
        final result = tProfilModel.toJson();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], 123456);
        expect(result['business_type'], 'retail');
        expect(result['business_name'], 'Boutique Example');
        expect(result['stripe_account_id'], 'acct_1234567890');
        expect(result['created_at'], '2023-01-10T08:00:00.000Z');
        expect(result['updated_at'], '2024-01-15T12:00:00.000Z');
        expect(result['owner'], isA<Map<String, dynamic>>());
        expect(result['owner']['id'], 'owner_abc123');
        expect(result['owner']['username'], 'john.doe');
        expect(result['owner']['firstName'], 'John');
        expect(result['owner']['lastName'], 'Doe');
        expect(result['owner']['email'], 'john.doe@example.com');
        expect(result['owner']['emailVerified'], true);
        expect(result['owner']['attributes'], isA<Map<String, dynamic>>());
        expect(result['owner']['attributes']['phoneNumber'], ['+221771234567']);
        expect(result['owner']['createdTimestamp'], 1673337600000);
        expect(result['owner']['enabled'], true);
        expect(result['owner']['totp'], false);
        expect(result['owner']['disableableCredentialTypes'], []);
        expect(result['owner']['requiredActions'], []);
        expect(result['owner']['notBefore'], 0);
      });

      test('should handle null stripeAccountId in toJson', () {
        // Arrange
        final model = ProfilModel(
          id: 1,
          businessType: 'test',
          businessName: 'Test',
          stripeAccountId: null,
          createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
          updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
          ownerId: 'owner1',
          username: 'user1',
          firstName: 'First',
          lastName: 'Last',
          email: 'test@test.com',
          emailVerified: false,
          phoneNumbers: [],
          createdTimestamp: 0,
          enabled: true,
          totp: false,
          disableableCredentialTypes: [],
          requiredActions: [],
          notBefore: 0,
        );

        // Act
        final result = model.toJson();

        // Assert
        expect(result['stripe_account_id'], isNull);
      });

      test('should create valid JSON that can be parsed back', () {
        // Act
        final json = tProfilModel.toJson();
        final parsedModel = ProfilModel.fromJson(json);

        // Assert
        expect(parsedModel.id, tProfilModel.id);
        expect(parsedModel.businessType, tProfilModel.businessType);
        expect(parsedModel.businessName, tProfilModel.businessName);
        expect(parsedModel.stripeAccountId, tProfilModel.stripeAccountId);
        expect(parsedModel.createdAt, tProfilModel.createdAt);
        expect(parsedModel.updatedAt, tProfilModel.updatedAt);
        expect(parsedModel.ownerId, tProfilModel.ownerId);
        expect(parsedModel.username, tProfilModel.username);
        expect(parsedModel.firstName, tProfilModel.firstName);
        expect(parsedModel.lastName, tProfilModel.lastName);
        expect(parsedModel.email, tProfilModel.email);
        expect(parsedModel.emailVerified, tProfilModel.emailVerified);
        expect(parsedModel.phoneNumbers, tProfilModel.phoneNumbers);
        expect(parsedModel.createdTimestamp, tProfilModel.createdTimestamp);
        expect(parsedModel.enabled, tProfilModel.enabled);
        expect(parsedModel.totp, tProfilModel.totp);
        expect(
            parsedModel.disableableCredentialTypes,
            tProfilModel.disableableCredentialTypes);
        expect(parsedModel.requiredActions, tProfilModel.requiredActions);
        expect(parsedModel.notBefore, tProfilModel.notBefore);
      });
    });
  });
}
