import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/profil/data/models/profil_model.dart';
import 'package:todouapp/features/profil/domain/repositories/i_profil_repository.dart';
import 'package:todouapp/features/profil/domain/usecases/get_profil.dart';

// Mock
class MockProfilRepository extends Mock implements IProfilRepository {}

void main() {
  late GetProfil usecase;
  late MockProfilRepository mockRepository;

  setUp(() {
    mockRepository = MockProfilRepository();
    usecase = GetProfil(mockRepository);
  });

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

  group('GetProfil UseCase', () {
    test('should get ProfilModel from the repository', () async {
      // Arrange
      when(() => mockRepository.getProfil())
          .thenAnswer((_) async => Right(tProfilModel));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(tProfilModel));
      verify(() => mockRepository.getProfil());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when repository returns NetworkFailure',
        () async {
      // Arrange
      when(() => mockRepository.getProfil())
          .thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Left(NetworkFailure()));
      verify(() => mockRepository.getProfil());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when repository returns ServerFailure',
        () async {
      // Arrange
      const errorMessage = 'Server error occurred';
      when(() => mockRepository.getProfil())
          .thenAnswer((_) async => Left(ServerFailure(message: errorMessage)));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Left(ServerFailure(message: errorMessage)));
      verify(() => mockRepository.getProfil());
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository exactly once when invoked', () async {
      // Arrange
      when(() => mockRepository.getProfil())
          .thenAnswer((_) async => Right(tProfilModel));

      // Act
      await usecase();

      // Assert
      verify(() => mockRepository.getProfil()).called(1);
    });

    test('should return correct Either type with Right', () async {
      // Arrange
      when(() => mockRepository.getProfil())
          .thenAnswer((_) async => Right(tProfilModel));

      // Act
      final result = await usecase();

      // Assert
      expect(result.isRight(), true);
      expect(result.isLeft(), false);
      result.fold(
        (failure) => fail('Should not be a failure'),
        (profil) {
          expect(profil, isA<ProfilModel>());
          expect(profil.id, 123456);
          expect(profil.businessName, 'Boutique Example');
          expect(profil.email, 'john.doe@example.com');
        },
      );
    });

    test('should return correct Either type with Left', () async {
      // Arrange
      when(() => mockRepository.getProfil())
          .thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await usecase();

      // Assert
      expect(result.isLeft(), true);
      expect(result.isRight(), false);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (profil) => fail('Should not return profil'),
      );
    });

    test('should handle ProfilModel with null stripeAccountId', () async {
      // Arrange
      final profilWithoutStripe = ProfilModel(
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

      when(() => mockRepository.getProfil())
          .thenAnswer((_) async => Right(profilWithoutStripe));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(profilWithoutStripe));
      result.fold(
        (failure) => fail('Should not be a failure'),
        (profil) => expect(profil.stripeAccountId, isNull),
      );
    });
  });
}
