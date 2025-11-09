import 'package:todouapp/core/di/injection.dart';
import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:todouapp/features/onboarding/domain/repositories/i_onboarding_repository.dart';
import 'package:todouapp/features/onboarding/domain/usecases/check_onboarding_status.dart';
import 'package:todouapp/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:todouapp/features/onboarding/presentation/bloc/onboarding_bloc.dart';

/// Configuration de l'injection de dépendances pour la feature Onboarding
/// Suit le pattern: BLoC → UseCase → Repository → DataSource
Future<void> setupOnboardingFeature() async {
  // REPOSITORY
  sl.registerLazySingleton<IOnboardingRepository>(
    () => OnboardingRepositoryImpl(
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  // USE CASES
  sl.registerLazySingleton(() => CompleteOnboarding(sl<IOnboardingRepository>()));
  sl.registerLazySingleton(() => CheckOnboardingStatus(sl<IOnboardingRepository>()));

  // BLOC
  sl.registerFactory(
    () => OnboardingBloc(
      completeOnboarding: sl<CompleteOnboarding>(),
      checkOnboardingStatus: sl<CheckOnboardingStatus>(),
    ),
  );
}
