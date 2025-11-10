import 'package:todouapp/core/types/future_result.dart';
import 'package:todouapp/features/auth/domain/repositories/i_pin_repository.dart';

/// Use case pour vérifier le PIN saisi
class VerifyPin {
  final IPinRepository _repository;

  VerifyPin(this._repository);

  FutureResult<bool> call(String pin) async {
    return await _repository.verifyPin(pin);
  }
}
