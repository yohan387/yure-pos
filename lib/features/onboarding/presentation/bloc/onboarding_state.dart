import 'package:equatable/equatable.dart';

/// États du BLoC Onboarding
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// État initial
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// État de chargement
class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// État quand l'onboarding est complété
class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

/// État d'erreur
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
