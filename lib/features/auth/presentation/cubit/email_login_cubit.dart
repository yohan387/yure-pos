import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/features/auth/domain/usecases/login_with_email.dart';
import 'package:todouapp/features/auth/presentation/cubit/email_login_state.dart';

/// Cubit pour gérer l'état de la connexion par email
/// Suit le pattern Clean Architecture: UI → Cubit → UseCase → Repository
class EmailLoginCubit extends Cubit<EmailLoginState> {
  final LoginWithEmail _loginWithEmail;

  EmailLoginCubit({required LoginWithEmail loginWithEmail})
      : _loginWithEmail = loginWithEmail,
        super(const EmailLoginState());

  /// Exécute la connexion avec email et mot de passe
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
      (response) {
        // Succès: l'OTP a été envoyé
        emit(state.copyWith(
          status: EmailLoginStatus.success,
          message: response.message,
          email: email,
        ));
      },
    );
  }

  /// Réinitialise l'état
  void reset() {
    emit(const EmailLoginState());
  }
}
