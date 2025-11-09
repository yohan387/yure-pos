import 'package:equatable/equatable.dart';

/// Événements du BLoC Onboarding
abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

/// Événement pour marquer l'onboarding comme complété
class CompleteOnboardingEvent extends OnboardingEvent {
  const CompleteOnboardingEvent();
}

/// Événement pour vérifier le statut de l'onboarding
class CheckOnboardingStatusEvent extends OnboardingEvent {
  const CheckOnboardingStatusEvent();
}
