part of 'stripe_payment_bloc.dart';

abstract class StripePaymentState extends Equatable {
  const StripePaymentState();

  @override
  List<Object> get props => [];
}

class StripePaymentInitial extends StripePaymentState {}

class StripePaymentLoading extends StripePaymentState {}

class StripePaymentSuccess extends StripePaymentState {
  final String transactionId;

  const StripePaymentSuccess({this.transactionId = ''});

  @override
  List<Object> get props => [transactionId];
}

class StripePaymentError extends StripePaymentState {
  final String message;

  const StripePaymentError(this.message);

  @override
  List<Object> get props => [message];
}

class LinkPaymentQrReady extends StripePaymentState {
  final String paymentLink;
  final String transactionRef;

  const LinkPaymentQrReady({
    required this.paymentLink,
    required this.transactionRef,
  });

  @override
  List<Object> get props => [paymentLink, transactionRef];
}
