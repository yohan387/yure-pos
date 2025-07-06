part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? message;
  final AuthStatus statusOtp;
  final String? accessToken;
  final bool isAuthenticated;
  final String? merchantName;

  const AuthState(
      {this.status = AuthStatus.initial,
      this.message,
      this.statusOtp = AuthStatus.initial,
      this.accessToken,
      this.isAuthenticated = false,
      this.merchantName = ''});

  AuthState copyWith(
      {AuthStatus? status,
      String? message,
      AuthStatus? statusOtp,
      String? accessToken,
      bool? isAuthenticated,
      String? merchantName}) {
    return AuthState(
        status: status ?? this.status,
        message: message ?? this.message,
        statusOtp: statusOtp ?? this.statusOtp,
        accessToken: accessToken ?? this.accessToken,
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        merchantName: merchantName ?? this.merchantName);
  }

  @override
  List<Object?> get props =>
      [status, message, accessToken, isAuthenticated, statusOtp, merchantName];
}
