import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/features/nfc/scanner_reader.dart';
import 'package:todouapp/features/payments/presentation/bloc/stripe_payment_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/page_loader.dart';
import '../../../transactions/presentation/bloc/transaction_bloc.dart';
import 'payment_response_page.dart';

class StripePaymentPage extends StatefulWidget {
  final double amount;

  const StripePaymentPage({Key? key, required this.amount}) : super(key: key);

  @override
  State<StripePaymentPage> createState() => _StripePaymentPageState();
}

class _StripePaymentPageState extends State<StripePaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Inserer une carte".toUpperCase(),
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Inter',
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<StripePaymentBloc, StripePaymentState>(
        listener: (context, state) {
          if (state is StripePaymentSuccess) {
            // Navigator.of(context).pop(true); // Retourne true si succès

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentSuccessPage(
                    amount: widget.amount,
                    transactionId: state.transactionId,
                    status: 'Succès',
                    network: 'CARD'),
              ),
            );
            context.read<TransactionBloc>().add(LoadInitialTransactionsEvent());
          } else if (state is StripePaymentError) {
            // 2. Afficher erreur
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 25.0),
                      child: Text(
                        "Veuillez insérer votre carte dans le terminal pour procéder au paiement.",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Inter',
                          color: textColor,
                          fontWeight: FontWeight.w300,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        // Navigator.pushNamed(context, RouteConstants.topTopay);
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ScannerReader(
                              amount: widget.amount,
                              currency: 'EUR',
                            ),
                          ),
                        );
                      },
                      child: Center(
                        child: Image.asset('assets/images/scan_image.png'),
                      ),
                    ),
                  ],
                ),
              ),
              if (state is StripePaymentLoading) const FullPageLoader(),
            ],
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<StripePaymentBloc, StripePaymentState>(
        builder: (context, state) {
          return Container(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: state is StripePaymentLoading
                        ? null
                        : () => context.read<StripePaymentBloc>().add(
                              ProcessStripePayment(widget.amount),
                            ),
                    child: renderConfirmButton(),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  renderConfirmButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
      child: Container(
        height: 50.0,
        width: double.infinity,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            'Saisir manuellement',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
