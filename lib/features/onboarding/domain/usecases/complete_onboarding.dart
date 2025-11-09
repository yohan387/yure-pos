import '../repositories/i_onboarding_repository.dart';

/// Use case pour marquer l'onboarding comme complété
class CompleteOnboarding {
  final IOnboardingRepository _repository;

  CompleteOnboarding(this._repository);

  Future<void> call() async {
    return await _repository.completeOnboarding();
  }
}
