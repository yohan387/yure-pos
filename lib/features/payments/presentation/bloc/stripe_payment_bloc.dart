import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:todouapp/core/constants/colors.dart';
import 'package:todouapp/core/utils/secure_storage.dart';

import '../../domain/repositories/stripe_payment_repository.dart';

part 'stripe_payment_event.dart';
part 'stripe_payment_state.dart';

class StripePaymentBloc extends Bloc<StripePaymentEvent, StripePaymentState> {
  final StripePaymentRepository repository;
  final SecureStorageService secureStorage;

  StripePaymentBloc({
    required this.repository,
    required this.secureStorage,
  }) : super(StripePaymentInitial()) {
    on<ProcessStripePayment>(_onProcessPayment);
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

      // 2. Créer l'intention de paiement
      final result = await repository.createPaymentIntent(event.amount);

      await result.fold(
        (failure) => throw Exception(failure.message),
        (response) async {
          // 3. Initialiser Stripe
          await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: response.clientSecret,
              //customerEphemeralKeySecret: response.ephemeralKey,
              // customerId: response.customerId,

              merchantDisplayName: 'TodouApp',
              //primaryButtonLabel: 'Payer',
              // applePay: PaymentSheetApplePay(
              //   merchantCountryCode: 'FR',
              // ),
              // googlePay: PaymentSheetGooglePay(
              //   merchantCountryCode: 'CI',
              //   currencyCode: 'XOF',
              // ),
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
      emit(StripePaymentError(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}
