import 'package:flutter/material.dart';
import 'package:todouapp/features/transactions/data/models/gateway_model.dart';

import '../../../../core/constants/colors.dart';
import '../../../mobile_payments/presentation/pages/mobile_money_contact_page.dart';
import '../../../mobile_payments/presentation/pages/om__payment_page.dart';

class PaymentGateway extends StatelessWidget {
  const PaymentGateway({
    Key? key,
    required this.gatewayModel,
  }) : super(key: key);
  final GatewayModel gatewayModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              if (gatewayModel.name.toUpperCase() == "ORANGE") {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OmPaymentPage(
                            network: gatewayModel.name.toUpperCase(),
                          )),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MobileMoneyContactPage(
                          network: gatewayModel.name.toUpperCase())),
                );
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.only(right: 5, left: 5, top: 10, bottom: 5),
              width: 75,
              child: Image.asset(
                gatewayModel.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Text(gatewayModel.name,
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Inter',
                  color: textColor,
                  fontWeight: FontWeight.w600))
        ],
      ),
    );
  }
}
