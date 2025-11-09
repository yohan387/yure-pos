import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/features/onboarding/domain/usecases/check_onboarding_status.dart';
import 'package:todouapp/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:todouapp/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:todouapp/features/onboarding/presentation/bloc/onboarding_state.dart';

/// BLoC pour gérer l'état de l'onboarding
/// Suit le pattern Clean Architecture: UI → BLoC → UseCase → Repository → DataSource
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CompleteOnboarding _completeOnboarding;
  final CheckOnboardingStatus _checkOnboardingStatus;

  OnboardingBloc({
    required CompleteOnboarding completeOnboarding,
    required CheckOnboardingStatus checkOnboardingStatus,
  })  : _completeOnboarding = completeOnboarding,
        _checkOnboardingStatus = checkOnboardingStatus,
        super(const OnboardingInitial()) {
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
    on<CheckOnboardingStatusEvent>(_onCheckOnboardingStatus);
  }

  /// Gère l'événement de complétion de l'onboarding
  Future<void> _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());
    try {
      await _completeOnboarding();
      emit(const OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError('Erreur lors de la sauvegarde: ${e.toString()}'));
    }
  }

  /// Gère l'événement de vérification du statut
  Future<void> _onCheckOnboardingStatus(
    CheckOnboardingStatusEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    try {
      final isCompleted = await _checkOnboardingStatus();
      if (isCompleted) {
        emit(const OnboardingCompleted());
      } else {
        emit(const OnboardingInitial());
      }
    } catch (e) {
      emit(OnboardingError('Erreur lors de la vérification: ${e.toString()}'));
    }
  }
}
