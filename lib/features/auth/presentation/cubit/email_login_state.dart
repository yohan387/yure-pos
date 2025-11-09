import 'package:equatable/equatable.dart';

enum EmailLoginStatus {
  initial,
  loading,
  success,
  failure,
}

class EmailLoginState extends Equatable {
  final EmailLoginStatus status;
  final String? message;
  final String? email;

  const EmailLoginState({
    this.status = EmailLoginStatus.initial,
    this.message,
    this.email,
  });

  EmailLoginState copyWith({
    EmailLoginStatus? status,
    String? message,
    String? email,
  }) {
    return EmailLoginState(
      status: status ?? this.status,
      message: message ?? this.message,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [status, message, email];
}
