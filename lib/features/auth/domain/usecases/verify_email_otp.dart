import 'package:todouapp/core/types/future_result.dart';
import 'package:todouapp/features/auth/domain/entities/auth_response.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';

class VerifyEmailOtp {
  final IAuthRepository _repository;

  VerifyEmailOtp(this._repository);

  FutureResult<AuthResponse> call(String email, String otp) async {
    return await _repository.verifyEmailOtp(email, otp);
  }
}
