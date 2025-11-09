import 'package:todouapp/core/types/future_result.dart';
import 'package:todouapp/features/auth/domain/entities/auth_response.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';

class LoginWithEmail {
  final IAuthRepository _repository;

  LoginWithEmail(this._repository);

  FutureResult<AuthResponse> call(String email, String password) async {
    return await _repository.loginWithEmail(email, password);
  }
}
