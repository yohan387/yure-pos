import 'package:todouapp/core/types/future_result.dart';
import 'package:todouapp/features/auth/domain/entities/auth_response.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';

class VerifyOtp {
  final IAuthRepository _repository;

  VerifyOtp(IAuthRepository repository) : _repository = repository;

  FutureResult<AuthResponse> call(String otp, String code) async {
    return await _repository.verifyOtp(otp, code);
  }
}
