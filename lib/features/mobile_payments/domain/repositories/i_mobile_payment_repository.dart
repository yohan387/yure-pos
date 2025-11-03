import 'package:dartz/dartz.dart';
import 'package:todouapp/core/errors/failures.dart';
import '../../data/models/mobile_payment_model.dart';

abstract class IMobilePaymentRepository {
  Future<Either<Failure, MobilePaymentInitResponse>> initPayment(
      MobilePaymentInitRequest request);
  Future<Either<Failure, MobilePaymentVerifyResponse>> verifyPayment(
      String transactionId);
  Future<Either<Failure, MobilePaymentVerifyResponse>> stripeVerifyPayment(
      String transactionId);
}
