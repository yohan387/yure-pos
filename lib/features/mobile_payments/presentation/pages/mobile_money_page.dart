import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/secure_storage.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../payments/presentation/pages/payment_response_page.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import '../bloc/mobile_payment_bloc.dart';

class MobilePaymentScreen extends StatefulWidget {
  final double amount;
  final String currency;
  final String network;
  final String customerPhone;
  final String? otp;
  const MobilePaymentScreen(
      {super.key,
      required this.amount,
      required this.currency,
      required this.network,
      required this.customerPhone,
      this.otp});

  @override
  _MobilePaymentScreenState createState() => _MobilePaymentScreenState();
}

class _MobilePaymentScreenState extends State<MobilePaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              'Paiement ${widget.amount} ${widget.currency}'.toUpperCase())),
      body: BlocConsumer<MobilePaymentBloc, MobilePaymentState>(
        listener: (context, state) {
          if (state is MobilePaymentError && state.isTimer) {
            final transaction = TransactionModel(
              id: 0,
              merchantId: 0,
              terminalId: 0,
              amount: widget.amount,
              currency: widget.currency,
              transactionRef: "${state.transactionId}",
              date: DateTime.now(),
              paymentMethod: 'Mobile Money',
              status: 'failed',
              customerPhone: widget.customerPhone,
              network: widget.network,
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.paymentDetail,
              (route) => false,
              arguments: transaction,
            );
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => PaymentSuccessPage(
            //         amount: widget.amount,
            //         transactionId: state.transactionId,
            //         status: 'Echec',
            //         network: widget.network),
            //   ),
            // );
          }
          if (state is MobilePaymentError) {
            CustomSnackbar.showError(context, state.message ?? '');
          }
          if (state is MobilePaymentSuccess) {
            final transaction = TransactionModel(
              id: 0,
              merchantId: 0,
              terminalId: 0,
              amount: widget.amount,
              currency: widget.currency,
              transactionRef: state.reference,
              date: DateTime.now(),
              paymentMethod: 'Mobile Money',
              status: 'succeeded',
              customerPhone: widget.customerPhone,
              network: widget.network,
            );

            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.paymentDetail,
              (route) => false,
              arguments: transaction,
            );
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (_) => PaymentSuccessPage(
            //         amount: widget.amount,
            //         transactionId: state.reference,
            //         status: 'Echec',
            //         network: widget.network),
            //   ),
            // );
            context.read<TransactionBloc>().add(LoadInitialTransactionsEvent());
          }
        },
        builder: (context, state) {
          if (state is MobilePaymentLoading) {
            return const Center(child: SpinKitThreeBounce(color: Colors.red));
          }

          if (state is MobilePaymentQrReady) {
            return _buildQrView(state);
          }

          if (state is MobilePaymentProcessing) {
            return _buildProcessingView(state);
          }

          // if (state is MobilePaymentSuccess) {
          //   return _buildSuccessView(state, widget.amount);
          // }

          // if (state is MobilePaymentError) {
          //   return _buildErrorView(state, widget.amount);
          // }

          return _buildInitialView();
        },
      ),
      bottomNavigationBar: BlocBuilder<MobilePaymentBloc, MobilePaymentState>(
        builder: (context, state) {
          return Container(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 50.0),
                    child: GestureDetector(
                      onTap: () =>
                          state is MobilePaymentLoading ? null : _initPayment(),
                      child: Container(
                        height: 50.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Démarrer le paiement',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Column(
        children: [
          Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
            child: Text(
              "Confirmer le paiement de",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              '${widget.amount} ${widget.currency}',
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                color: greenColor,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Text(
              widget.network.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                color: Colors.black,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Image.asset(
              widget.network.toUpperCase() == 'WAVE'
                  ? 'assets/images/wave.png'
                  : widget.network.toUpperCase() == 'MTN'
                      ? 'assets/images/momo.png'
                      : widget.network.toUpperCase() == 'OM'
                          ? 'assets/images/orange.png'
                          : 'assets/images/moov.png',
              height: 150,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(MobilePaymentQrReady state) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 45.0),
            child: Text(
              "Utilisez l'application Wave pour scanner ce QR code et finaliser votre paiement en toute sécurité.",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: textColor,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: QrImageView(
              data: state.qrCodeUrl,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Text(
              "Scannez pour payer avec Wave",
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Text(
              'Temps : ${state.remainingSeconds}s',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView(MobilePaymentProcessing state) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 130),
            child: Text(
              "Confirmer le paiement de",
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Inter',
                color: textColor,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              '${widget.amount} ${widget.currency}',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Inter',
                color: greenColor,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Text(
              widget.network.toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Inter',
                color: Colors.black,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Image.asset(
              widget.network.toUpperCase() == 'WAVE'
                  ? 'assets/images/wave.png'
                  : widget.network.toUpperCase() == 'MTN'
                      ? 'assets/images/momo.png'
                      : widget.network.toUpperCase() == 'OM'
                          ? 'assets/images/orange.png'
                          : 'assets/images/moov.png',
              height: 150,
            ),
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Vérification du paiement...',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              color: primaryColor,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '${state.remainingSeconds}s restantes',
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              color: Colors.red,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Transaction: ${state.transactionId}',
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Inter',
              color: Colors.black,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(MobilePaymentSuccess state, double amount) {
    return PaymentSuccessPage(
        transactionId: state.reference,
        amount: amount,
        status: 'Succès',
        network: widget.network);
  }

  void _initPayment() async {
    final secureStorage = SecureStorageService();
    final marchantId = await secureStorage.getMarchandId();
    final terminalId = await secureStorage.getTerminalId();
    context.read<MobilePaymentBloc>().add(
          MobileInitPaymentEvent(
              amount: widget.amount,
              currency: widget.currency,
              terminalId: int.parse('$terminalId'),
              merchantId: int.parse('$marchantId'),
              network: widget.network.toUpperCase(),
              customerPhone: widget.customerPhone,
              operatorOtp: widget.otp ?? ''),
        );
  }
}
