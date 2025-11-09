import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/features/auth/domain/usecases/resend_email_otp.dart';
import 'package:todouapp/features/auth/presentation/cubit/email_otp_state.dart';

class EmailOtpCubit extends Cubit<EmailOtpState> {
  final ResendEmailOtp _resendEmailOtp;
  Timer? _timer;
  Timer? _cooldownTimer;
  String? _currentEmail;

  EmailOtpCubit({required ResendEmailOtp resendEmailOtp})
      : _resendEmailOtp = resendEmailOtp,
        super(const EmailOtpState());

  void setEmail(String email) {
    _currentEmail = email;
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
      } else {
        timer.cancel();
        emit(state.copyWith(
          status: EmailOtpStatus.failure,
          message: 'Le code OTP a expiré',
        ));
      }
    });
  }

  void startResendCooldown() {
    emit(state.copyWith(resendCooldown: 60));
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCooldown > 0) {
        emit(state.copyWith(resendCooldown: state.resendCooldown - 1));
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> resendOtp() async {
    if (state.resendCooldown > 0 || _currentEmail == null) {
      return;
    }

    emit(state.copyWith(status: EmailOtpStatus.resending));

    final result = await _resendEmailOtp(_currentEmail!);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: EmailOtpStatus.failure,
          message: failure.message,
        ));
      },
      (response) {
        emit(state.copyWith(
          status: EmailOtpStatus.resent,
          message: response.message,
          remainingSeconds: 300,
        ));
        startTimer();
        startResendCooldown();
      },
    );
  }

  void reset() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    emit(const EmailOtpState());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    return super.close();
  }
}
