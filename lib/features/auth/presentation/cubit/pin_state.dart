import 'package:equatable/equatable.dart';

/// Mode d'utilisation de l'écran PIN
enum PinMode {
  setup,   // Création + Confirmation (APP-008/009)
  verify,  // Vérification au login (APP-011/012)
  change,  // Changement de PIN (APP-SETTINGS-002)
}

/// Étape/statut du processus PIN
enum PinStep {
  entering,         // Saisie en cours
  verifying,        // Vérification backend/hash en cours
  creationDone,     // Création terminée, passer à confirmation
  confirmationDone, // Confirmation terminée
  success,          // Succès final
  error,            // Erreur générale
  mismatch,         // PIN ne correspond pas (confirmation)
  incorrect,        // PIN incorrect (login)
  blocked,          // Bloqué après 3 tentatives (APP-013)
}

class PinState extends Equatable {
  final PinMode mode;
  final PinStep step;
  final String currentPin;
  final String? createdPin;  // Pour setup: PIN créé à confirmer
  final String? errorMessage;
  final int attemptsLeft;     // Pour verify mode (max 3)

  const PinState({
    required this.mode,
    this.step = PinStep.entering,
    this.currentPin = '',
    this.createdPin,
    this.errorMessage,
    this.attemptsLeft = 3,
  });

  // Helpers
  bool get isSetupMode => mode == PinMode.setup;
  bool get isVerifyMode => mode == PinMode.verify;
  bool get isChangeMode => mode == PinMode.change;

  bool get isPinComplete => currentPin.length == 4;
  bool get canDelete => currentPin.isNotEmpty;
  bool get showError =>
      step == PinStep.mismatch ||
      step == PinStep.incorrect ||
      step == PinStep.error;

  bool get isCreationStep => isSetupMode && createdPin == null;
  bool get isConfirmationStep => isSetupMode && createdPin != null;

  String get title {
    if (isVerifyMode) return 'Saisissez votre code PIN';
    if (isCreationStep) return 'Créez un code PIN';
    if (isConfirmationStep) return 'Confirmez votre code PIN';
    return 'Code PIN';
  }

  String get subtitle {
    if (isVerifyMode) return '';
    if (isCreationStep) return 'Pour sécuriser l\'accès rapide';
    if (isConfirmationStep) return 'Saisissez à nouveau votre code PIN';
    return '';
  }

  PinState copyWith({
    PinMode? mode,
    PinStep? step,
    String? currentPin,
    String? createdPin,
    String? errorMessage,
    int? attemptsLeft,
  }) {
    return PinState(
      mode: mode ?? this.mode,
      step: step ?? this.step,
      currentPin: currentPin ?? this.currentPin,
      createdPin: createdPin ?? this.createdPin,
      errorMessage: errorMessage,
      attemptsLeft: attemptsLeft ?? this.attemptsLeft,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        step,
        currentPin,
        createdPin,
        errorMessage,
        attemptsLeft,
      ];
}
