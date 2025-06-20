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
