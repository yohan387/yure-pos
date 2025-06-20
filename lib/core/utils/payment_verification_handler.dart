import 'dart:async';
import '../../features/mobile_payments/presentation/bloc/mobile_payment_bloc.dart';

class PaymentVerificationHandler {
  static const int totalTime = 180; // en secondes
  static const int checkInterval = 10; // vérification toutes les 10s

  Timer? _countdownTimer;
  int _remainingSeconds = totalTime;

  Future<void> start({
    required String transactionId,
    required MobilePaymentBloc bloc,
  }) async {
    _cancelAll();

    // Lancer le compte à rebours visible
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        _cancelAll();
        bloc.add(MobileVerifyPaymentEvent(transactionId, isAutoCheck: false));
      } else if (bloc.state is MobilePaymentProcessing) {
        bloc.emit(
          (bloc.state as MobilePaymentProcessing).copyWith(
            remainingSeconds: _remainingSeconds,
          ),
        );
      }
    });

    // Lancer la boucle de vérification toutes les 10s
    while (_remainingSeconds > 0) {
      await Future.delayed(const Duration(seconds: checkInterval));
      if (_remainingSeconds <= 0) break;

      bloc.add(MobileVerifyPaymentEvent(transactionId, isAutoCheck: true));
    }
  }

  void _cancelAll() {
    _countdownTimer?.cancel();
  }

  void dispose() {
    _cancelAll();
  }
}
