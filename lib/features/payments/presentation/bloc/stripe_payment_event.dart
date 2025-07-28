part of 'stripe_payment_bloc.dart';

abstract class StripePaymentEvent extends Equatable {
  const StripePaymentEvent();

  @override
  List<Object> get props => [];
}

class ProcessStripePayment extends StripePaymentEvent {
  final double amount;

  const ProcessStripePayment(this.amount);

  @override
  List<Object> get props => [amount];
}

class StripeInitPaymentLinkEvent extends StripePaymentEvent {
  final dynamic amount;
  final String currency;
  final int terminalId;
  final int merchantId;

  const StripeInitPaymentLinkEvent({
    required this.amount,
    required this.currency,
    required this.terminalId,
    required this.merchantId,
  });

  @override
  List<Object> get props => [
        amount,
        currency,
        terminalId,
        merchantId,
      ];
}
