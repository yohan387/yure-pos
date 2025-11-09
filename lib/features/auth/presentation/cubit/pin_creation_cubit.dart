import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/features/auth/presentation/cubit/pin_creation_state.dart';

class PinCreationCubit extends Cubit<PinCreationState> {
  PinCreationCubit() : super(const PinCreationState());

  void addDigit(String digit) {
    if (state.currentPin.length < 4) {
      final newPin = state.currentPin + digit;
      emit(state.copyWith(
        currentPin: newPin,
        status: newPin.length == 4
            ? PinCreationStatus.complete
            : PinCreationStatus.entering,
      ));
    }
  }

  void deleteLastDigit() {
    if (state.currentPin.isNotEmpty) {
      final newPin = state.currentPin.substring(0, state.currentPin.length - 1);
      emit(state.copyWith(
        currentPin: newPin,
        status: newPin.isEmpty
            ? PinCreationStatus.initial
            : PinCreationStatus.entering,
      ));
    }
  }

  void clearPin() {
    emit(const PinCreationState());
  }

  void reset() {
    emit(const PinCreationState());
  }
}
