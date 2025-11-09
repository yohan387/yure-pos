import 'package:todouapp/core/types/future_result.dart';
import 'package:todouapp/features/auth/domain/entities/auth_response.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';

class VerifyCode {
  final IAuthRepository _repository;

  VerifyCode(IAuthRepository repository) : _repository = repository;

  FutureResult<AuthResponse> call(String code) async {
    return await _repository.verifyCode(code);
  }
}
