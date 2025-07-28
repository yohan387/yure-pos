part of 'mobile_payment_bloc.dart';

abstract class MobilePaymentState extends Equatable {
  const MobilePaymentState();

  @override
  List<Object> get props => [];
}

class MobilePaymentInitial extends MobilePaymentState {}

class MobilePaymentLoading extends MobilePaymentState {}

class MobilePaymentQrReady extends MobilePaymentState {
  final String qrCodeUrl;
  final String transactionId;
  final int remainingSeconds;

  const MobilePaymentQrReady(
      {required this.qrCodeUrl,
      required this.transactionId,
      required this.remainingSeconds});

  @override
  List<Object> get props => [qrCodeUrl, transactionId];
}

class MobilePaymentProcessing extends MobilePaymentState {
  final String transactionId;
  final int remainingSeconds;
  final String? qrCodeUrl;

  const MobilePaymentProcessing({
    required this.transactionId,
    required this.remainingSeconds,
    this.qrCodeUrl,
  });
  MobilePaymentProcessing copyWith({
    String? transactionId,
    int? remainingSeconds,
    String? qrCodeUrl,
  }) {
    return MobilePaymentProcessing(
      transactionId: transactionId ?? this.transactionId,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
    );
  }

  @override
  List<Object> get props => [transactionId, remainingSeconds, qrCodeUrl ?? ''];
}

class MobilePaymentSuccess extends MobilePaymentState {
  final String reference;
  final DateTime date;

  const MobilePaymentSuccess({
    required this.reference,
    required this.date,
  });

  @override
  List<Object> get props => [reference, date];
}

class MobilePaymentError extends MobilePaymentState {
  final String message;
  final String? transactionId;
  final bool isTimer;

  const MobilePaymentError(this.message, this.isTimer, {this.transactionId});

  @override
  List<Object> get props => [message, isTimer];
}

class MobilePaymentPending extends MobilePaymentState {
  final String message;
  final DateTime timestamp;

  MobilePaymentPending(
    this.message,
  ) : timestamp = DateTime.now();

  @override
  List<Object> get props => [message, timestamp];
}
