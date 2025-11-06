import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:todouapp/features/auth/domain/usecases/verify_code.dart';

// Mock
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late VerifyCode usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = VerifyCode(mockRepository);
  });

  // Test data
  final tCode = 'TERMINAL123';
  final tAuthResponse = AuthResponseModel(
    message: 'OTP sent successfully',
    accessToken: '',
    marchandId: 'merchant_001',
    terminalId: 'terminal_001',
    merchantFirstName: 'Bob',
  );

  test('should get AuthResponseModel from the repository when code is verified successfully', () async {
    // arrange
    when(() => mockRepository.verifyCode(any()))
        .thenAnswer((_) async => Right(tAuthResponse));

    // act
    final result = await usecase.call(tCode);

    // assert
    expect(result, equals(Right(tAuthResponse)));
    verify(() => mockRepository.verifyCode(tCode));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should forward the call to repository with correct code parameter', () async {
    // arrange
    when(() => mockRepository.verifyCode(any()))
        .thenAnswer((_) async => Right(tAuthResponse));

    // act
    await usecase.call(tCode);

    // assert
    verify(() => mockRepository.verifyCode(tCode)).called(1);
  });

  test('should return ServerFailure when repository returns failure', () async {
    // arrange
    final tFailure = ServerFailure(message: 'Terminal not found');
    when(() => mockRepository.verifyCode(any()))
        .thenAnswer((_) async => Left(tFailure));

    // act
    final result = await usecase.call(tCode);

    // assert
    expect(result, equals(Left(tFailure)));
    verify(() => mockRepository.verifyCode(tCode));
  });

  test('should return NetworkFailure when there is no internet connection', () async {
    // arrange
    when(() => mockRepository.verifyCode(any()))
        .thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase.call(tCode);

    // assert
    expect(result, equals(Left(NetworkFailure())));
    verify(() => mockRepository.verifyCode(tCode));
  });

  test('should return exactly what the repository returns without modification', () async {
    // arrange
    final tCustomAuthResponse = AuthResponseModel(
      message: 'Custom OTP message',
      accessToken: 'temp_token',
      marchandId: 'merchant_xyz',
      terminalId: 'terminal_xyz',
      merchantFirstName: 'Alice',
    );
    when(() => mockRepository.verifyCode(any()))
        .thenAnswer((_) async => Right(tCustomAuthResponse));

    // act
    final result = await usecase.call(tCode);

    // assert
    expect(result, equals(Right(tCustomAuthResponse)));
    result.fold(
      (failure) => fail('Should not return failure'),
      (authResponse) {
        expect(authResponse.message, tCustomAuthResponse.message);
        expect(authResponse.accessToken, tCustomAuthResponse.accessToken);
        expect(authResponse.marchandId, tCustomAuthResponse.marchandId);
        expect(authResponse.terminalId, tCustomAuthResponse.terminalId);
        expect(authResponse.merchantFirstName, tCustomAuthResponse.merchantFirstName);
      },
    );
  });
}
