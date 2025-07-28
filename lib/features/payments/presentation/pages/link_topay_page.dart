import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:todouapp/core/constants/colors.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/button_widget.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../mobile_payments/presentation/bloc/mobile_payment_bloc.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../bloc/stripe_payment_bloc.dart';
import 'payment_response_page.dart';

class LinkTopayPage extends StatefulWidget {
  final double amount;
  final int terminalId;
  final int merchantId;
  final String currency;
  const LinkTopayPage(
      {super.key,
      required this.amount,
      required this.terminalId,
      required this.merchantId,
      required this.currency});

  @override
  _LinkTopayPageState createState() => _LinkTopayPageState();
}

class _LinkTopayPageState extends State<LinkTopayPage> {
  late String amount;

  @override
  void initState() {
    super.initState();
    amount = widget.amount.toString();
    context.read<StripePaymentBloc>().add(StripeInitPaymentLinkEvent(
        amount: widget.currency == "EUR"
            ? (widget.amount * 100).ceil()
            : widget.amount,
        currency: widget.currency,
        terminalId: widget.terminalId,
        merchantId: widget.merchantId));
  }

  Widget renderAmount() {
    TextStyle amountStyle = const TextStyle(
      fontSize: 30.0,
      fontFamily: 'Inter',
      color: Colors.black,
      fontWeight: FontWeight.w400,
    );

    TextStyle currencyStyle = const TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.w400,
      color: Colors.black54,
    );

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Montant',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: widget.amount.toString(), style: amountStyle),
                  TextSpan(text: ' ${widget.currency}', style: currencyStyle),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Divider(thickness: 1, color: Colors.grey.shade300),
          ),
        ],
      ),
    );
  }

  Widget renderQrOrLoading() {
    return BlocBuilder<StripePaymentBloc, StripePaymentState>(
      builder: (context, state) {
        if (state is StripePaymentLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: CircularProgressIndicator(),
          );
        } else if (state is LinkPaymentQrReady) {
          return QrImageView(
            data: state.paymentLink,
            size: 200,
            backgroundColor: Colors.white,
          );
        } else if (state is StripePaymentError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Erreur: ${state.message}',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MobilePaymentBloc, MobilePaymentState>(
      listener: (context, state) {
        if (state is MobilePaymentSuccess) {
          // Paiement validé, redirige vers une page de succès
          final transaction = TransactionModel(
            id: 0,
            merchantId: 0,
            terminalId: 0,
            amount: widget.amount,
            currency: widget.currency,
            transactionRef: state.reference,
            date: DateTime.now(),
            paymentMethod: 'CARD',
            status: 'succeeded',
            customerPhone: "",
            network: "CARD",
          );

          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteConstants.paymentDetail,
            (route) => false,
            arguments: transaction,
          );

          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text("Paiement reussi !")),
          // );
        } else if (state is MobilePaymentPending) {
          // Paiement en cours
          CustomSnackbar.showWarning(context, state.message);
        } else if (state is MobilePaymentError) {
          // Paiement échoué

          CustomSnackbar.showError(
              context, state.message ?? 'Échec du paiement');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Confirmer la transaction".toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Inter',
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 25.0),
                child: Text(
                  "Saisissez le montant total de la transaction en ${widget.currency}.",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              renderAmount(),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 50,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Text(
                        "Vérifiez ce qui précède avant de confirmer.",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: renderQrOrLoading(),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Text(
                        "Scannez pour payer",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Boutons en bas hors du bloc coloré
              Padding(
                padding: const EdgeInsets.only(
                    right: 15, left: 15, top: 35, bottom: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: CancelButton(text: "ANNULER"),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        text: "VÉRIFIER",
                        onPressed: () {
                          final state = context.read<StripePaymentBloc>().state;
                          if (state is LinkPaymentQrReady) {
                            context.read<MobilePaymentBloc>().add(
                                  StripeVerifyPaymentEvent(
                                      state.transactionRef),
                                );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Lien de paiement non prêt"),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
