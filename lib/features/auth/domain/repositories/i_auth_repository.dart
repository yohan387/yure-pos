import 'package:todouapp/core/types/future_result.dart';
import 'package:todouapp/features/auth/domain/entities/auth_response.dart';

abstract class IAuthRepository {
  FutureResult<AuthResponse> verifyCode(String code);

  FutureResult<AuthResponse> verifyOtp(String otp, String code);

  FutureResult<AuthResponse> loginWithEmail(String email, String password);

  FutureResult<AuthResponse> resendEmailOtp(String email);

  FutureResult<AuthResponse> verifyEmailOtp(String email, String otp);
}
