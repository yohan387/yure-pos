part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class VerifyCodeEvent extends AuthEvent {
  final String code;

  const VerifyCodeEvent(this.code);

  @override
  List<Object> get props => [code];
}

class VerifyOtpEvent extends AuthEvent {
  final String otp;
  final String code;

  const VerifyOtpEvent(this.otp, this.code);

  @override
  List<Object> get props => [otp, code];
}

class CheckAuthStatusEvent extends AuthEvent {}
