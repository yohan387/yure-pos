import 'package:flutter/material.dart';
import 'package:todouapp/features/transactions/data/models/gateway_model.dart';

import '../../../../core/constants/colors.dart';

class PaymentGateway extends StatelessWidget {
  const PaymentGateway({
    Key? key,
    required this.gatewayModel,
  }) : super(key: key);
  final GatewayModel gatewayModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding:
                const EdgeInsets.only(right: 0, left: 0, top: 10, bottom: 5),
            width: 100,
            child: Image.asset(
              gatewayModel.imageUrl,
              fit: BoxFit.contain,
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
