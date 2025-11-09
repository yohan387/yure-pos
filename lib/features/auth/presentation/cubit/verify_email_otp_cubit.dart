import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/features/auth/domain/usecases/verify_email_otp.dart';
import 'package:todouapp/features/auth/presentation/cubit/verify_email_otp_state.dart';

class VerifyEmailOtpCubit extends Cubit<VerifyEmailOtpState> {
  final VerifyEmailOtp _verifyEmailOtp;

  VerifyEmailOtpCubit({
    required VerifyEmailOtp verifyEmailOtp,
  })  : _verifyEmailOtp = verifyEmailOtp,
        super(const VerifyEmailOtpState());

  Future<void> verifyOtp(String email, String otp) async {
    emit(state.copyWith(status: VerifyEmailOtpStatus.loading));

    final result = await _verifyEmailOtp(email, otp);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: VerifyEmailOtpStatus.failure,
          message: failure.message,
        ));
      },
      (response) {
        // Token storage is now handled by AuthRepositoryImpl
        emit(state.copyWith(
          status: VerifyEmailOtpStatus.success,
          message: response.message,
        ));
      },
    );
  }

  void reset() {
    emit(const VerifyEmailOtpState());
  }
}
