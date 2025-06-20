import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/amout_format.dart';
import '../../data/models/balance_model.dart';

class HoHeader extends StatelessWidget {
  final BalanceModel balance;
  const HoHeader({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 15),
              child: Text('Total Balance',
                  style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Inter',
                      color: textColor,
                      fontWeight: FontWeight.w600)),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: AmountFormatter.format(balance.amount),
                      style: TextStyle(
                          fontSize: 40,
                          fontFamily: 'Inter',
                          color: textColor,
                          fontWeight: FontWeight.w400)),
                  TextSpan(
                      text: ' Fcfa',
                      style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Inter',
                          color: textColor,
                          fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            Text("4.08% aujourd'hui",
                style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    color: greenColor,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        InkWell(
          onTap: () {},
          child: Image.asset(
            'assets/images/user-image-with-black-background.png',
            height: 60,
          ),
        ),
      ],
    );
  }
}
