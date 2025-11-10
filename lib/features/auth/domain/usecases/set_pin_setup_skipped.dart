import 'package:todouapp/core/types/future_result.dart';
import 'package:todouapp/features/auth/domain/repositories/i_pin_repository.dart';

/// Use case pour marquer la configuration du PIN comme ignorée
class SetPinSetupSkipped {
  final IPinRepository _repository;

  SetPinSetupSkipped(this._repository);

  FutureResult<void> call(bool skipped) async {
    return await _repository.setPinSetupSkipped(skipped);
  }
}
