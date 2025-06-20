import 'package:flutter/material.dart';
import 'package:todouapp/core/constants/colors.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/amout_format.dart';
import '../../../../core/widgets/button_widget.dart';

class PaymentSuccessPage extends StatelessWidget {
  final double amount;
  final String? transactionId;
  final String status;
  final String network;

  const PaymentSuccessPage(
      {Key? key,
      required this.amount,
      this.transactionId,
      required this.network,
      required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          status,
          style: TextStyle(fontFamily: 'Inter'),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status == 'Succès'
                      ? greenColor
                      : redColor, // Couleur de fond du cercle
                ),
                child: Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset(status == 'Succès'
                        ? 'assets/images/check.png'
                        : 'assets/images/error.png'),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                textAlign: TextAlign.center,
                status == 'Succès'
                    ? 'La transaction de ${AmountFormatter.format(amount)} XOF par $network a réussie'
                    : 'La transaction de ${AmountFormatter.format(amount)} XOF par $network a echouée',
                style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    color: textColor,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 100),
              CustomButton(
                text: 'Retour à l\'accueil',
                onPressed: () {
                  // Retour à l'écran d'accueil
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteConstants.home,
                    (route) => false,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
