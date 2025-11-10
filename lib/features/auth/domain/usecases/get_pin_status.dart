import 'package:todouapp/features/auth/domain/repositories/i_pin_repository.dart';

/// Résultat du statut du PIN
class PinStatus {
  final bool hasPinConfigured;
  final bool hasPinSkipped;

  PinStatus({
    required this.hasPinConfigured,
    required this.hasPinSkipped,
  });

  bool get needsPinSetup => !hasPinConfigured && !hasPinSkipped;
  bool get needsPinVerification => hasPinConfigured;
  bool get canSkipToAccueil => hasPinSkipped;
}

/// Use case pour récupérer le statut du PIN
class GetPinStatus {
  final IPinRepository _repository;

  GetPinStatus(this._repository);

  Future<PinStatus> call() async {
    final hasPinConfiguredResult = await _repository.hasPinConfigured();
    final hasPinSkippedResult = await _repository.hasPinSetupSkipped();

    final hasPinConfigured = hasPinConfiguredResult.fold(
      (failure) => false,
      (value) => value,
    );

    final hasPinSkipped = hasPinSkippedResult.fold(
      (failure) => false,
      (value) => value,
    );

    return PinStatus(
      hasPinConfigured: hasPinConfigured,
      hasPinSkipped: hasPinSkipped,
    );
  }
}
