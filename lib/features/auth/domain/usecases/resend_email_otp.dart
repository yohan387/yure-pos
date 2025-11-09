import 'package:todouapp/core/types/future_result.dart';
import 'package:todouapp/features/auth/domain/entities/auth_response.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';

class ResendEmailOtp {
  final IAuthRepository _repository;

  ResendEmailOtp(this._repository);

  FutureResult<AuthResponse> call(String email) async {
    return await _repository.resendEmailOtp(email);
  }
}
