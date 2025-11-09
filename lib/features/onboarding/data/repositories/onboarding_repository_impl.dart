import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/features/onboarding/domain/repositories/i_onboarding_repository.dart';

/// Implémentation du repository d'onboarding
/// Utilise SecureStorageService pour persister l'état de l'onboarding
class OnboardingRepositoryImpl implements IOnboardingRepository {
  final SecureStorageService _secureStorage;

  OnboardingRepositoryImpl({required SecureStorageService secureStorage})
      : _secureStorage = secureStorage;

  @override
  Future<bool> hasCompletedOnboarding() async {
    return await _secureStorage.hasCompletedOnboarding();
  }

  @override
  Future<void> completeOnboarding() async {
    return await _secureStorage.setOnboardingCompleted();
  }
}
