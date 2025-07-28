import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:todouapp/core/constants/colors.dart';
import 'package:todouapp/core/utils/paiement_amount.dart';
import 'package:todouapp/core/utils/secure_storage.dart';
import 'package:todouapp/features/payments/domain/usescases/init_link_payment.dart';

import '../../data/models/stripe_payment_intent_response.dart';
import '../../domain/repositories/stripe_payment_repository.dart';

part 'stripe_payment_event.dart';
part 'stripe_payment_state.dart';

class StripePaymentBloc extends Bloc<StripePaymentEvent, StripePaymentState> {
  final StripePaymentRepository repository;
  final SecureStorageService secureStorage;
  final InitLinkPayment initLinkPayment;

  StripePaymentBloc(
      {required this.repository,
      required this.secureStorage,
      required this.initLinkPayment})
      : super(StripePaymentInitial()) {
    on<ProcessStripePayment>(_onProcessPayment);
    on<StripeInitPaymentLinkEvent>(_onInitLinkPayment);
  }

  Future<void> _onProcessPayment(
    ProcessStripePayment event,
    Emitter<StripePaymentState> emit,
  ) async {
    emit(StripePaymentLoading());

    try {
      // 1. Vérifier le token
      final token = await secureStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      }

      // Convertir le montant en centimes
      int montantPourStripe =
          PaiementMontant.convertToStripeAmount(event.amount, 'EUR');

      // 2. Créer l'intention de paiement
      final result = await repository.createPaymentIntent(montantPourStripe);

      await result.fold(
        (failure) => throw Exception(failure.message),
        (response) async {
          // 3. Initialiser Stripe
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: response.clientSecret,
              merchantDisplayName: 'TodouApp',
              style: ThemeMode.light,
              appearance: PaymentSheetAppearance(
                colors: PaymentSheetAppearanceColors(
                    primary: greenColor, primaryText: Colors.black),
              ),
            ),
          );

          // 4. Afficher le formulaire de paiement
          await Stripe.instance.presentPaymentSheet();

          // 5. Succès
          emit(StripePaymentSuccess(
            transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
          ));
        },
      );
    } catch (e) {
      log('bloc stripe $e');
      if (e is StripeException) {
        switch (e.error.code) {
          case FailureCode.Canceled:
            emit(StripePaymentError(
                "Le paiement a été annulé par l'utilisateur."));
            break;
          default:
            emit(StripePaymentError(
                e.error.localizedMessage ?? 'Erreur de paiement'));
        }
      } else {
        emit(StripePaymentError('Erreur inconnue : ${e.toString()}'));
      }
    }
  }

  Future<void> _onInitLinkPayment(
    StripeInitPaymentLinkEvent event,
    Emitter<StripePaymentState> emit,
  ) async {
    emit(StripePaymentLoading());

    final request = StripeLinkPaymentInitRequest(
      amount: event.amount,
      currency: event.currency,
      terminalId: event.terminalId,
      merchantId: event.merchantId,
    );

    final result = await initLinkPayment(request);

    result.fold(
      (failure) => emit(StripePaymentError(failure.message)),
      (response) {
        emit(LinkPaymentQrReady(
          transactionRef: response.transactionRef,
          paymentLink: response.paymentLink,
        ));
      },
    );
  }
}
