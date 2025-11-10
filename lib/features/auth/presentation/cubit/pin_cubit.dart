import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/features/auth/domain/usecases/save_pin.dart';
import 'package:todouapp/features/auth/domain/usecases/set_pin_setup_skipped.dart';
import 'package:todouapp/features/auth/domain/usecases/verify_pin.dart';
import 'package:todouapp/features/auth/presentation/cubit/pin_state.dart';

class PinCubit extends Cubit<PinState> {
  final SavePin _savePin;
  final SetPinSetupSkipped _setPinSetupSkipped;
  final VerifyPin? _verifyPin;
  final SecureStorageService? _secureStorage;

  PinCubit({
    required SavePin savePin,
    required SetPinSetupSkipped setPinSetupSkipped,
    VerifyPin? verifyPin,
    SecureStorageService? secureStorage,
    required PinMode mode,
  })  : _savePin = savePin,
        _setPinSetupSkipped = setPinSetupSkipped,
        _verifyPin = verifyPin,
        _secureStorage = secureStorage,
        super(PinState(mode: mode));

  void addDigit(String digit) {
    if (state.currentPin.length < 4) {
      final newPin = state.currentPin + digit;
      emit(state.copyWith(
        currentPin: newPin,
        step: PinStep.entering,
        errorMessage: null,
      ));

      // Auto-action quand 4 chiffres
      if (newPin.length == 4) {
        _handlePinComplete(newPin);
      }
    }
  }

  void deleteLastDigit() {
    if (state.currentPin.isNotEmpty) {
      emit(state.copyWith(
        currentPin:
            state.currentPin.substring(0, state.currentPin.length - 1),
        step: PinStep.entering,
        errorMessage: null,
      ));
    }
  }

  Future<void> _handlePinComplete(String pin) async {
    if (state.isSetupMode) {
      await _handleSetupMode(pin);
    } else if (state.isVerifyMode) {
      await _handleVerifyMode(pin);
    }
  }

  Future<void> _handleSetupMode(String pin) async {
    if (state.isCreationStep) {
      // STEP 1: Création - stocker et passer à confirmation
      emit(state.copyWith(
        step: PinStep.creationDone,
        createdPin: pin,
        currentPin: '',
      ));
    } else {
      // STEP 2: Confirmation - comparer
      if (pin == state.createdPin) {
        // Match! Sauvegarder
        emit(state.copyWith(step: PinStep.verifying));

        final result = await _savePin(pin);
        result.fold(
          (failure) => emit(state.copyWith(
            step: PinStep.error,
            errorMessage: failure.message,
          )),
          (_) => emit(state.copyWith(step: PinStep.success)),
        );
      } else {
        // Mismatch
        emit(state.copyWith(
          step: PinStep.mismatch,
          errorMessage: 'Les codes ne correspondent pas',
          currentPin: '',
        ));
      }
    }
  }

  void restart() {
    emit(PinState(mode: state.mode));
  }

  Future<void> skipSetup() async {
    emit(state.copyWith(step: PinStep.verifying));
    final result = await _setPinSetupSkipped(true);
    result.fold(
      (failure) => emit(state.copyWith(
        step: PinStep.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(step: PinStep.success)),
    );
  }

  Future<void> _handleVerifyMode(String pin) async {
    if (_verifyPin == null) {
      emit(state.copyWith(
        step: PinStep.error,
        errorMessage: 'VerifyPin use case not provided',
      ));
      return;
    }

    emit(state.copyWith(step: PinStep.verifying));

    final result = await _verifyPin(pin);
    result.fold(
      (failure) => emit(state.copyWith(
        step: PinStep.error,
        errorMessage: failure.message,
      )),
      (isValid) async {
        if (isValid) {
          emit(state.copyWith(step: PinStep.success));
        } else {
          // PIN incorrect - décrémenter les tentatives
          final newAttempts = state.attemptsLeft - 1;
          if (newAttempts == 0) {
            // APP-013: Plus de tentatives - déconnecter
            if (_secureStorage != null) {
              await _secureStorage.deleteToken();
            }
            emit(state.copyWith(
              step: PinStep.blocked,
              errorMessage: 'Nombre de tentatives dépassé. Vous allez être déconnecté.',
              attemptsLeft: 0,
            ));
          } else {
            emit(state.copyWith(
              step: PinStep.incorrect,
              errorMessage: 'Code PIN incorrect ($newAttempts ${newAttempts > 1 ? "tentatives restantes" : "tentative restante"})',
              attemptsLeft: newAttempts,
              currentPin: '',
            ));
          }
        }
      },
    );
  }
}
