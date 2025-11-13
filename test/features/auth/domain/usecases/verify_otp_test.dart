import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import 'package:todouapp/features/auth/data/models/auth_response_model.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:todouapp/features/auth/domain/usecases/verify_otp.dart';

// Mock
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late VerifyOtp usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = VerifyOtp(mockRepository);
  });

  // Test data
  final tOtp = '1234';
  final tCode = 'TEST123';
  final tAuthResponse = AuthResponseModel(
    message: 'Authentication successful',
    accessToken: 'jwt_token_abc123',
    marchandId: 'merchant_789',
    terminalId: 'terminal_456',
    merchantFirstName: 'Jane',
  );

  test(
      'should get AuthResponse entity from the repository when OTP is verified successfully',
      () async {
    // arrange
    when(() => mockRepository.verifyOtp(any(), any()))
        .thenAnswer((_) async => Right(tAuthResponse.toEntity()));

    // act
    final result = await usecase.call(tOtp, tCode);

    // assert
    expect(result.isRight(), true);
    verify(() => mockRepository.verifyOtp(tOtp, tCode));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should forward the call to repository with correct parameters',
      () async {
    // arrange
    when(() => mockRepository.verifyOtp(any(), any()))
        .thenAnswer((_) async => Right(tAuthResponse.toEntity()));

    // act
    await usecase.call(tOtp, tCode);

    // assert
    verify(() => mockRepository.verifyOtp(tOtp, tCode)).called(1);
  });

  test('should return ServerFailure when repository returns failure', () async {
    // arrange
    final tFailure = ServerFailure(message: 'Invalid OTP code');
    when(() => mockRepository.verifyOtp(any(), any()))
        .thenAnswer((_) async => Left(tFailure));

    // act
    final result = await usecase.call(tOtp, tCode);

    // assert
    expect(result, equals(Left(tFailure)));
    verify(() => mockRepository.verifyOtp(tOtp, tCode));
  });

  test('should return NetworkFailure when there is no internet connection',
      () async {
    // arrange
    when(() => mockRepository.verifyOtp(any(), any()))
        .thenAnswer((_) async => Left(NetworkFailure()));

    // act
    final result = await usecase.call(tOtp, tCode);

    // assert
    expect(result, equals(Left(NetworkFailure())));
    verify(() => mockRepository.verifyOtp(tOtp, tCode));
  });

  test('should pass both OTP and code parameters in correct order', () async {
    // arrange
    final tDifferentOtp = '9999';
    final tDifferentCode = 'CODE999';
    when(() => mockRepository.verifyOtp(any(), any()))
        .thenAnswer((_) async => Right(tAuthResponse.toEntity()));

    // act
    await usecase.call(tDifferentOtp, tDifferentCode);

    // assert
    verify(() => mockRepository.verifyOtp(tDifferentOtp, tDifferentCode));
  });

  test('should handle empty OTP and code strings', () async {
    // arrange
    final tEmptyOtp = '';
    final tEmptyCode = '';
    when(() => mockRepository.verifyOtp(any(), any())).thenAnswer((_) async =>
        Left(ServerFailure(message: 'OTP and code cannot be empty')));

    // act
    final result = await usecase.call(tEmptyOtp, tEmptyCode);

    // assert
    expect(result.isLeft(), true);
    verify(() => mockRepository.verifyOtp(tEmptyOtp, tEmptyCode));
  });

  test('should return exactly what the repository returns without modification',
      () async {
    // arrange
    final tCustomAuthResponse = AuthResponseModel(
      message: 'Custom message',
      accessToken: 'custom_token',
      marchandId: 'custom_merchant',
      terminalId: 'custom_terminal',
      merchantFirstName: 'CustomName',
    );
    when(() => mockRepository.verifyOtp(any(), any()))
        .thenAnswer((_) async => Right(tCustomAuthResponse.toEntity()));

    // act
    final result = await usecase.call(tOtp, tCode);

    // assert
    expect(result.isRight(), true);
    result.fold(
      (failure) => fail('Should not return failure'),
      (authResponse) {
        expect(authResponse.message, tCustomAuthResponse.message);
        expect(authResponse.accessToken, tCustomAuthResponse.accessToken);
        expect(authResponse.marchandId, tCustomAuthResponse.marchandId);
        expect(authResponse.terminalId, tCustomAuthResponse.terminalId);
        expect(authResponse.merchantFirstName,
            tCustomAuthResponse.merchantFirstName);
      },
    );
  });
}
