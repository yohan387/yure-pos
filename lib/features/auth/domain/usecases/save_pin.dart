import 'package:todouapp/core/types/future_result.dart';
import 'package:todouapp/features/auth/domain/repositories/i_pin_repository.dart';

/// Use case pour sauvegarder un code PIN
/// Hash le PIN et le stocke de manière sécurisée
class SavePin {
  final IPinRepository _repository;

  SavePin(this._repository);

  /// Sauvegarde un code PIN après l'avoir hashé
  ///
  /// [pin] Le code PIN à sauvegarder (4 chiffres)
  ///
  /// Returns [Right(null)] en cas de succès
  /// Returns [Left(Failure)] en cas d'erreur
  FutureResult<void> call(String pin) async {
    return await _repository.savePin(pin);
  }
}
