import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/exceptions.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/core/network/i_network_info.dart';
import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/features/auth/data/datasources/i_auth_data_source.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';
import 'package:todouapp/features/auth/data/repositories/auth_repository_impl.dart';

// Mocks
class MockAuthDataSource extends Mock implements IAuthDataSource {}
class MockNetworkInfo extends Mock implements INetworkInfo {}
class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthDataSource mockDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockSecureStorageService mockSecureStorage;

  setUp(() {
    mockDataSource = MockAuthDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockSecureStorage = MockSecureStorageService();
    repository = AuthRepositoryImpl(
      dataSource: mockDataSource,
      networkInfo: mockNetworkInfo,
      secureStorage: mockSecureStorage,
    );
  });

  // Test data
  final tCode = 'TEST123';
  final tOtp = '1234';
  final tAuthResponse = AuthResponseModel(
    message: 'Success',
    accessToken: 'test_token_123',
    marchandId: 'merchant_1',
    terminalId: 'terminal_1',
    merchantFirstName: 'John',
  );

  group('verifyCode', () {
    test('should check if the device is online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.verifyCode(any()))
          .thenAnswer((_) async => tAuthResponse);

      // act
      await repository.verifyCode(tCode);

      // assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return AuthResponse entity when the call to data source is successful', () async {
        // arrange
        when(() => mockDataSource.verifyCode(any()))
            .thenAnswer((_) async => tAuthResponse);

        // act
        final result = await repository.verifyCode(tCode);

        // assert
        verify(() => mockDataSource.verifyCode(tCode));
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should return Right'),
          (authResponse) {
            expect(authResponse.message, tAuthResponse.message);
            expect(authResponse.accessToken, tAuthResponse.accessToken);
            expect(authResponse.marchandId, tAuthResponse.marchandId);
          },
        );
      });

      test('should call data source with correct code', () async {
        // arrange
        when(() => mockDataSource.verifyCode(any()))
            .thenAnswer((_) async => tAuthResponse);

        // act
        await repository.verifyCode(tCode);

        // assert
        verify(() => mockDataSource.verifyCode(tCode)).called(1);
      });

      test('should return ServerFailure when data source throws ServerException', () async {
        // arrange
        final tServerException = ServerException(message: 'Terminal not found');
        when(() => mockDataSource.verifyCode(any()))
            .thenThrow(tServerException);

        // act
        final result = await repository.verifyCode(tCode);

        // assert
        verify(() => mockDataSource.verifyCode(tCode));
        expect(result, equals(Left(ServerFailure(message: 'Terminal not found'))));
      });

      test('should return ServerFailure with correct message from exception', () async {
        // arrange
        final tErrorMessage = 'Invalid terminal code';
        final tServerException = ServerException(message: tErrorMessage);
        when(() => mockDataSource.verifyCode(any()))
            .thenThrow(tServerException);

        // act
        final result = await repository.verifyCode(tCode);

        // assert
        expect(result, equals(Left(ServerFailure(message: tErrorMessage))));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure when device has no internet', () async {
        // act
        final result = await repository.verifyCode(tCode);

        // assert
        verifyZeroInteractions(mockDataSource);
        expect(result, equals(Left(NetworkFailure())));
      });

      test('should not call data source when there is no network', () async {
        // act
        await repository.verifyCode(tCode);

        // assert
        verifyNever(() => mockDataSource.verifyCode(any()));
      });
    });
  });

  group('verifyOtp', () {
    setUp(() {
      // Setup storage mocks for all verifyOtp tests
      when(() => mockSecureStorage.saveToken(any())).thenAnswer((_) async => {});
      when(() => mockSecureStorage.saveMarchandId(any())).thenAnswer((_) async => {});
      when(() => mockSecureStorage.saveTerminalId(any())).thenAnswer((_) async => {});
      when(() => mockSecureStorage.saveMerchantName(any())).thenAnswer((_) async => {});
    });

    test('should check if the device is online', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockDataSource.verifyOtp(any(), any()))
          .thenAnswer((_) async => tAuthResponse);

      // act
      await repository.verifyOtp(tOtp, tCode);

      // assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return AuthResponse entity when the call to data source is successful', () async {
        // arrange
        when(() => mockDataSource.verifyOtp(any(), any()))
            .thenAnswer((_) async => tAuthResponse);

        // act
        final result = await repository.verifyOtp(tOtp, tCode);

        // assert
        verify(() => mockDataSource.verifyOtp(tOtp, tCode));
        verify(() => mockSecureStorage.saveToken(any()));
        verify(() => mockSecureStorage.saveMarchandId(any()));
        verify(() => mockSecureStorage.saveTerminalId(any()));
        verify(() => mockSecureStorage.saveMerchantName(any()));
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should return Right'),
          (authResponse) {
            expect(authResponse.message, tAuthResponse.message);
            expect(authResponse.accessToken, tAuthResponse.accessToken);
            expect(authResponse.marchandId, tAuthResponse.marchandId);
          },
        );
      });

      test('should call data source with correct otp and code', () async {
        // arrange
        when(() => mockDataSource.verifyOtp(any(), any()))
            .thenAnswer((_) async => tAuthResponse);

        // act
        await repository.verifyOtp(tOtp, tCode);

        // assert
        verify(() => mockDataSource.verifyOtp(tOtp, tCode)).called(1);
      });

      test('should return ServerFailure when data source throws ServerException', () async {
        // arrange
        final tServerException = ServerException(message: 'Invalid OTP');
        when(() => mockDataSource.verifyOtp(any(), any()))
            .thenThrow(tServerException);

        // act
        final result = await repository.verifyOtp(tOtp, tCode);

        // assert
        verify(() => mockDataSource.verifyOtp(tOtp, tCode));
        expect(result, equals(Left(ServerFailure(message: 'Invalid OTP'))));
      });

      test('should return ServerFailure with correct message from exception', () async {
        // arrange
        final tErrorMessage = 'OTP expired';
        final tServerException = ServerException(message: tErrorMessage);
        when(() => mockDataSource.verifyOtp(any(), any()))
            .thenThrow(tServerException);

        // act
        final result = await repository.verifyOtp(tOtp, tCode);

        // assert
        expect(result, equals(Left(ServerFailure(message: tErrorMessage))));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NetworkFailure when device has no internet', () async {
        // act
        final result = await repository.verifyOtp(tOtp, tCode);

        // assert
        verifyZeroInteractions(mockDataSource);
        expect(result, equals(Left(NetworkFailure())));
      });

      test('should not call data source when there is no network', () async {
        // act
        await repository.verifyOtp(tOtp, tCode);

        // assert
        verifyNever(() => mockDataSource.verifyOtp(any(), any()));
      });
    });
  });
}
