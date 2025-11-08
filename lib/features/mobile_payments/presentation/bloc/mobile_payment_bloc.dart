import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/utils/idempotency_key_manager.dart';
import '../../../../core/utils/payment_verification_handler.dart';
import '../../data/models/mobile_payment_model.dart';
import '../../domain/usecases/init_payment.dart';
import '../../domain/usecases/stripe_verify_payment.dart';
import '../../domain/usecases/verify_payment.dart';

part 'mobile_payment_event.dart';
part 'mobile_payment_state.dart';

class MobilePaymentBloc extends Bloc<MobilePaymentEvent, MobilePaymentState> {
  final InitPayment initPayment;
  final VerifyPayment verifyPayment;
  final StripeVerifyPayment stripeVerifyPayment;
  final IdempotencyKeyManager idempotencyKeyManager;

  Timer? _verificationTimer;
  Timer? _countdownTimer;
  int _remainingSeconds = 180;
  final PaymentVerificationHandler _verificationHandler =
      PaymentVerificationHandler();

  // Stockage temporaire de la clé d'idempotence pour retry
  String? _currentIdempotencyKey;

  MobilePaymentBloc({
    required this.initPayment,
    required this.verifyPayment,
    required this.stripeVerifyPayment,
    required this.idempotencyKeyManager,
  }) : super(MobilePaymentInitial()) {
    on<MobileInitPaymentEvent>(_onInitPayment);
    on<MobileVerifyPaymentEvent>(_onVerifyPayment);
    on<StripeVerifyPaymentEvent>(_onStripeVerifyPayment);
  }

  @override
  Future<void> close() {
    // _verificationTimer?.cancel();
    _verificationHandler.dispose();

    return super.close();
  }

  Future<void> _onInitPayment(
    MobileInitPaymentEvent event,
    Emitter<MobilePaymentState> emit,
  ) async {
    // Générer la clé d'idempotence (seulement si pas déjà en cours de retry)
    _currentIdempotencyKey ??= idempotencyKeyManager.generateKey();

    emit(MobilePaymentLoading());

    final request = MobilePaymentInitRequest(
      amount: event.amount,
      currency: event.currency,
      terminalId: event.terminalId,
      merchantId: event.merchantId,
      network: event.network,
      customerPhone: event.customerPhone,
      operatorOtp: event.operatorOtp,
    );

    final result = await initPayment(
      request: request,
      idempotencyKey: _currentIdempotencyKey!,
    );

    result.fold(
      (failure) {
        // En cas d'erreur, garder la clé pour retry potentiel
        emit(MobilePaymentError(failure.message, false));
      },
      (response) {
        // Succès - réinitialiser la clé pour le prochain paiement
        _currentIdempotencyKey = null;

        if (event.network == 'WAVE') {
          emit(MobilePaymentQrReady(
            transactionId: response.transactionId,
            remainingSeconds: 180,
            qrCodeUrl: response.paymentUrl,
          ));
          _verificationHandler.start(
            transactionId: response.transactionId,
            bloc: this,
          );
        } else {
          // // Pour paiement direct, démarrer la vérification automatique
          // emit(MobilePaymentProcessing(
          //   transactionId: response.transactionId,
          //   remainingSeconds: 30,
          // ));
          // _startAutoVerification(response.transactionId);

          emit(MobilePaymentProcessing(
            transactionId: response.transactionId,
            remainingSeconds: 180,
          ));
          _verificationHandler.start(
            transactionId: response.transactionId,
            bloc: this,
          );
        }
      },
    );
  }

  void _startAutoVerification(String transactionId) {
    _cancelTimers();
    _remainingSeconds = 180;

    emit(MobilePaymentProcessing(
      transactionId: transactionId,
      remainingSeconds: _remainingSeconds,
    ));

    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      if (_remainingSeconds <= 0) {
        _cancelTimers();
        add(MobileVerifyPaymentEvent(transactionId, isAutoCheck: false));
      } else if (state is MobilePaymentProcessing) {
        emit((state as MobilePaymentProcessing)
            .copyWith(remainingSeconds: _remainingSeconds));
      }
    });

    // Lancer une boucle manuelle async
    _launchVerificationLoop(transactionId);
  }

  void _cancelTimers() {
    _countdownTimer?.cancel();
    _verificationTimer?.cancel();
  }

  void _launchVerificationLoop(String transactionId) async {
    while (_remainingSeconds > 0) {
      await Future.delayed(const Duration(seconds: 10));
      if (_remainingSeconds <= 0) break;
      add(MobileVerifyPaymentEvent(transactionId, isAutoCheck: true));
    }
  }

  Future<void> _onVerifyPayment(
    MobileVerifyPaymentEvent event,
    Emitter<MobilePaymentState> emit,
  ) async {
    // Ne pas émettre de loading pour les vérifications automatiques
    if (!event.isAutoCheck) {
      emit(MobilePaymentLoading());
    }

    final result = await verifyPayment(event.transactionId);

    result.fold(
      (failure) {
        if (event.isAutoCheck) {
          // Pour les vérifications auto, mettre à jour le compteur
          if (state is MobilePaymentProcessing) {
            final currentState = state as MobilePaymentProcessing;
            emit(currentState.copyWith(
              remainingSeconds: currentState.remainingSeconds - 5,
            ));
          }
        } else {
          emit(MobilePaymentError(failure.message, true,
              transactionId: event.transactionId));
        }
      },
      (response) {
        _verificationTimer?.cancel();
        if (response.status.toLowerCase() == 'success' ||
            response.status.toLowerCase() == "succeeded") {
          _cancelTimers();
          emit(MobilePaymentSuccess(
            reference: response.reference,
            date: response.date,
          ));
        } else if (!event.isAutoCheck) {
          // Dernière tentative échouée après 180 sec
          _cancelTimers();
          emit(MobilePaymentError('Paiement expiré', true,
              transactionId: event.transactionId));
        }
      },
    );
  }

  Future<void> _onStripeVerifyPayment(
    StripeVerifyPaymentEvent event,
    Emitter<MobilePaymentState> emit,
  ) async {
    final result = await verifyPayment(event.transactionId);

    result.fold(
      (failure) {
        log(failure.toString());
        emit(MobilePaymentError(failure.message, true,
            transactionId: event.transactionId));
      },
      (response) {
        log(response.status.toString());
        if (response.status.toLowerCase() == 'success' ||
            response.status.toLowerCase() == "succeeded") {
          emit(MobilePaymentSuccess(
            reference: response.reference,
            date: response.date,
          ));
        } else if (response.status.toLowerCase() == 'pending') {
          emit(MobilePaymentPending("Paiement en cours"));
        } else if (response.status.toLowerCase() == 'failed') {
          emit(MobilePaymentError("Paiement echoué", true,
              transactionId: event.transactionId));
        }
      },
    );
  }
}
