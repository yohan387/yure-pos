part of 'mobile_payment_bloc.dart';

abstract class MobilePaymentEvent extends Equatable {
  const MobilePaymentEvent();

  @override
  List<Object> get props => [];
}

class MobileInitPaymentEvent extends MobilePaymentEvent {
  final double amount;
  final String currency;
  final int terminalId;
  final int merchantId;
  final String network; // 'qr' ou 'direct'
  final String customerPhone;
  final String operatorOtp;

  const MobileInitPaymentEvent({
    required this.amount,
    required this.currency,
    required this.terminalId,
    required this.merchantId,
    required this.network,
    required this.customerPhone,
    required this.operatorOtp,
  });

  @override
  List<Object> get props => [
        amount,
        currency,
        terminalId,
        merchantId,
        network,
        customerPhone,
        operatorOtp,
      ];
}

class MobileVerifyPaymentEvent extends MobilePaymentEvent {
  final String transactionId;
  final bool isAutoCheck; // Pour différencier la vérification automatique

  const MobileVerifyPaymentEvent(this.transactionId,
      {this.isAutoCheck = false});

  @override
  List<Object> get props => [transactionId, isAutoCheck];
}
