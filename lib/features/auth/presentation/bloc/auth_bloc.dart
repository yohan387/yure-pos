import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/core/utils/token_validator.dart';
import 'package:todouapp/features/auth/domain/usecases/verify_code.dart';
import 'package:todouapp/features/auth/domain/usecases/verify_otp.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/event_bus.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final VerifyCode verifyCode;
  final VerifyOtp verifyOtp;
  final SecureStorageService secureStorage;

  AuthBloc({
    required this.verifyCode,
    required this.verifyOtp,
    required this.secureStorage,
  }) : super(const AuthState()) {
    on<VerifyCodeEvent>(_onVerifyCode);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onVerifyCode(
    VerifyCodeEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    final result = await verifyCode(event.code);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.failure,
        message: failure.message,
      )),
      (response) => emit(state.copyWith(
          status: AuthStatus.success,
          message: response.message,
          merchantName: response.merchantFirstName)),
    );
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(
        status: AuthStatus.loading, statusOtp: AuthStatus.loading));

    try {
      final result = await verifyOtp(event.otp, event.code);

      await result.fold(
        (failure) async {
          emit(state.copyWith(
            message: failure.message,
            statusOtp: AuthStatus.failure,
          ));
        },
        (response) async {
          await secureStorage.saveToken(response.accessToken);
          await secureStorage.saveMarchandId(response.marchandId);
          await secureStorage.saveTerminalId(response.terminalId);
          await secureStorage.saveMerchantName(response.merchantFirstName);

          if (!emit.isDone) {
            // Vérification cruciale
            emit(state.copyWith(
                status: AuthStatus.success,
                message: response.message,
                statusOtp: AuthStatus.success,
                accessToken: response.accessToken,
                isAuthenticated: true,
                merchantName: response.merchantFirstName));
          }
        },
      );
    } catch (e) {
      if (!emit.isDone) {
        emit(state.copyWith(
          status: AuthStatus.failure,
          message: 'An unexpected error occurred',
        ));
      }
    }
  }

  // Future<void> _onCheckAuthStatus(
  //   CheckAuthStatusEvent event,
  //   Emitter<AuthState> emit,
  // ) async {
  //   final token = await secureStorage.getToken();
  //   final isValid = TokenValidator.isTokenValid(token);

  //   emit(state.copyWith(
  //     isAuthenticated: isValid,
  //     accessToken: isValid ? token : null,
  //   ));
  // }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = await secureStorage.getToken();
      TokenValidator.isTokenValid(token);
      emit(state.copyWith(
        isAuthenticated: true,
        accessToken: token,
      ));
    } on TokenExpiredException {
      await secureStorage.deleteToken();
      emit(state.copyWith(isAuthenticated: false));
      eventBus.fire(TokenExpiredEvent());
    }
  }
}
