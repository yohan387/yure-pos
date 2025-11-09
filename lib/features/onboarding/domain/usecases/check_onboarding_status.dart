import '../repositories/i_onboarding_repository.dart';

/// Use case pour vérifier si l'onboarding a été complété
class CheckOnboardingStatus {
  final IOnboardingRepository _repository;

  CheckOnboardingStatus(this._repository);

  Future<bool> call() async {
    return await _repository.hasCompletedOnboarding();
  }
}
