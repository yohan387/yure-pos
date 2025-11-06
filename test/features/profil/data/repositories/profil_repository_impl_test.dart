import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/i_network_info.dart';
import 'package:todouapp/features/profil/data/datasources/i_profil_data_source.dart';
import 'package:todouapp/features/profil/data/models/profil_model.dart';
import 'package:todouapp/features/profil/data/repositories/profil_repository_impl.dart';

// Mocks
class MockProfilDataSource extends Mock implements IProfilDataSource {}

class MockNetworkInfo extends Mock implements INetworkInfo {}

void main() {
  late ProfilRepositoryImpl repository;
  late MockProfilDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockDataSource = MockProfilDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = ProfilRepositoryImpl(
      dataSource: mockDataSource,
      networkInfo: mockNetworkInfo,
    );
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

  group('ProfilRepositoryImpl', () {
    group('getProfil', () {
      test('should check if device is online', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.getProfil())
            .thenAnswer((_) async => tProfilModel);

        // Act
        await repository.getProfil();

        // Assert
        verify(() => mockNetworkInfo.isConnected);
      });

      test('should return NetworkFailure when device is offline', () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.getProfil();

        // Assert
        expect(result, Left(NetworkFailure()));
        verify(() => mockNetworkInfo.isConnected);
        verifyNever(() => mockDataSource.getProfil());
      });

      test('should return ProfilModel when data source call is successful',
          () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.getProfil())
            .thenAnswer((_) async => tProfilModel);

        // Act
        final result = await repository.getProfil();

        // Assert
        expect(result, Right(tProfilModel));
        verify(() => mockNetworkInfo.isConnected);
        verify(() => mockDataSource.getProfil());
      });

      test('should return ServerFailure when data source throws ServerException',
          () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.getProfil())
            .thenThrow(ServerException(message: 'Failed to fetch profil'));

        // Act
        final result = await repository.getProfil();

        // Assert
        expect(result, Left(ServerFailure(message: 'Failed to fetch profil')));
        verify(() => mockNetworkInfo.isConnected);
        verify(() => mockDataSource.getProfil());
      });

      test(
          'should return ServerFailure with default message when ServerException has no message',
          () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.getProfil())
            .thenThrow(ServerException(message: ''));

        // Act
        final result = await repository.getProfil();

        // Assert
        expect(result, Left(ServerFailure(message: '')));
        verify(() => mockNetworkInfo.isConnected);
        verify(() => mockDataSource.getProfil());
      });

      test('should return Right with ProfilModel containing null stripeAccountId',
          () async {
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

        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.getProfil())
            .thenAnswer((_) async => profilWithoutStripe);

        // Act
        final result = await repository.getProfil();

        // Assert
        expect(result, Right(profilWithoutStripe));
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not be a failure'),
          (profil) => expect(profil.stripeAccountId, isNull),
        );
      });

      test('should propagate ServerException with custom error message',
          () async {
        // Arrange
        const customErrorMessage = 'Authentication token expired';
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockDataSource.getProfil())
            .thenThrow(ServerException(message: customErrorMessage));

        // Act
        final result = await repository.getProfil();

        // Assert
        expect(result, Left(ServerFailure(message: customErrorMessage)));
        verify(() => mockNetworkInfo.isConnected);
        verify(() => mockDataSource.getProfil());
      });

      test('should return correct Either type with Left for network failure',
          () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

        // Act
        final result = await repository.getProfil();

        // Assert
        expect(result.isLeft(), true);
        expect(result.isRight(), false);
        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (profil) => fail('Should not return profil'),
        );
      });
    });
  });
}
