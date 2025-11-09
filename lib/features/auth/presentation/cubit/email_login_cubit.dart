import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/features/auth/domain/usecases/login_with_email.dart';
import 'package:todouapp/features/auth/presentation/cubit/email_login_state.dart';

class EmailLoginCubit extends Cubit<EmailLoginState> {
  final LoginWithEmail _loginWithEmail;

  EmailLoginCubit({required LoginWithEmail loginWithEmail})
      : _loginWithEmail = loginWithEmail,
        super(const EmailLoginState());

  Future<void> loginWithEmail(String email, String password) async {
    emit(state.copyWith(status: EmailLoginStatus.loading));

    final result = await _loginWithEmail(email, password);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: EmailLoginStatus.failure,
          message: failure.message,
        ));
      },
      (authResponse) {
        emit(state.copyWith(
          status: EmailLoginStatus.success,
          message: authResponse.message,
          email: email,
        ));
      },
    );
  }

  void reset() {
    emit(const EmailLoginState());
  }
}
