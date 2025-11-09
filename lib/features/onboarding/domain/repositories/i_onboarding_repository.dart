/// Interface pour le repository d'onboarding
/// Cette interface définit le contrat pour la gestion de l'état de l'onboarding
abstract class IOnboardingRepository {
  /// Vérifie si l'utilisateur a complété l'onboarding
  Future<bool> hasCompletedOnboarding();

  /// Marque l'onboarding comme complété
  Future<void> completeOnboarding();
}
