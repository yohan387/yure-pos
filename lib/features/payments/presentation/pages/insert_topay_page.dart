import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/core/constants/colors.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/button_widget.dart';
import '../../../mobile_payments/presentation/bloc/mobile_payment_bloc.dart';
import '../../../nfc/scanner_reader.dart';
import '../bloc/stripe_payment_bloc.dart';

class InsertTopayPage extends StatefulWidget {
  final double amount;

  final String currency;
  const InsertTopayPage(
      {super.key, required this.amount, required this.currency});

  @override
  _InsertTopayPageState createState() => _InsertTopayPageState();
}

class _InsertTopayPageState extends State<InsertTopayPage> {
  late String amount;

  @override
  void initState() {
    super.initState();
    amount = widget.amount.toString();
    // context.read<StripePaymentBloc>().add(StripeInitPaymentLinkEvent(
    //     amount: widget.currency == "EUR"
    //         ? (widget.amount * 100).ceil()
    //         : widget.amount,
    //     currency: widget.currency,
    //     terminalId: widget.terminalId,
    //     merchantId: widget.merchantId));
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<MobilePaymentBloc, MobilePaymentState>(
      listener: (context, state) {},
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ScannerReader(
                                  amount: widget.amount,
                                  currency: widget.currency,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Placer votre carte',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 17,
                                fontFamily: 'Inter',
                                color: primaryColor,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/insert_card.png',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
                      child: Image.asset(
                        'assets/images/direction.png',
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 20.0),
                      child: Text(
                        "Insérer votre carte ici !",
                        style: TextStyle(
                          fontSize: 17,
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
                        text: "VALIDER",
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            RouteConstants.accueil,
                            (route) => false,
                          );
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
