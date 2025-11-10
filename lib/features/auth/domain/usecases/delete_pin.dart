import 'package:todouapp/core/types/future_result.dart';
import 'package:todouapp/features/auth/domain/repositories/i_pin_repository.dart';

/// Use case pour supprimer le PIN
class DeletePin {
  final IPinRepository _repository;

  DeletePin(this._repository);

  FutureResult<void> call() async {
    return await _repository.deletePin();
  }
}
