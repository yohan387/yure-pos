import 'package:equatable/equatable.dart';

enum EmailOtpStatus {
  initial,
  loading,
  success,
  failure,
  resending,
  resent,
}

class EmailOtpState extends Equatable {
  final EmailOtpStatus status;
  final String? message;
  final int remainingSeconds;
  final int resendCooldown;

  const EmailOtpState({
    this.status = EmailOtpStatus.initial,
    this.message,
    this.remainingSeconds = 300,
    this.resendCooldown = 0,
  });

  EmailOtpState copyWith({
    EmailOtpStatus? status,
    String? message,
    int? remainingSeconds,
    int? resendCooldown,
  }) {
    return EmailOtpState(
      status: status ?? this.status,
      message: message ?? this.message,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      resendCooldown: resendCooldown ?? this.resendCooldown,
    );
  }

  @override
  List<Object?> get props =>
      [status, message, remainingSeconds, resendCooldown];
}
