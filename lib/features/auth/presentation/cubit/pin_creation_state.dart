import 'package:equatable/equatable.dart';

enum PinCreationStatus {
  initial,
  entering,
  complete,
}

class PinCreationState extends Equatable {
  final PinCreationStatus status;
  final String currentPin;
  final String? message;

  const PinCreationState({
    this.status = PinCreationStatus.initial,
    this.currentPin = '',
    this.message,
  });

  bool get isPinComplete => currentPin.length == 4;
  bool get canDelete => currentPin.isNotEmpty;

  PinCreationState copyWith({
    PinCreationStatus? status,
    String? currentPin,
    String? message,
  }) {
    return PinCreationState(
      status: status ?? this.status,
      currentPin: currentPin ?? this.currentPin,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, currentPin, message];
}
