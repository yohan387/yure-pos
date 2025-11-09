import 'package:equatable/equatable.dart';

enum VerifyEmailOtpStatus {
  initial,
  loading,
  success,
  failure,
}

class VerifyEmailOtpState extends Equatable {
  final VerifyEmailOtpStatus status;
  final String? message;

  const VerifyEmailOtpState({
    this.status = VerifyEmailOtpStatus.initial,
    this.message,
  });

  VerifyEmailOtpState copyWith({
    VerifyEmailOtpStatus? status,
    String? message,
  }) {
    return VerifyEmailOtpState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
