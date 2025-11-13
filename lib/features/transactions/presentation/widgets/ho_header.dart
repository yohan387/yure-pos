import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/amout_format.dart';
import '../../data/models/balance_model.dart';

class HoHeader extends StatefulWidget {
  final BalanceModel balance;
  const HoHeader({super.key, required this.balance});

  @override
  _HoHeaderState createState() => _HoHeaderState();
}

class _HoHeaderState extends State<HoHeader> {
  late double oldAmount;

  @override
  void initState() {
    super.initState();
    oldAmount = widget.balance.amount;
  }

  @override
  void didUpdateWidget(covariant HoHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance.amount != widget.balance.amount) {
      oldAmount = oldWidget.balance.amount;
    }
  }

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
            TweenAnimationBuilder<double>(
              tween:
                  Tween<double>(begin: oldAmount, end: widget.balance.amount),
              duration: const Duration(seconds: 1),
              builder: (context, value, child) {
                return RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: AmountFormatter.format(value),
                          style: TextStyle(
                              fontSize: 40,
                              fontFamily: 'Inter',
                              color: textColor,
                              fontWeight: FontWeight.w400)),
                      TextSpan(
                          text: ' €',
                          style: TextStyle(
                              fontSize: 25,
                              fontFamily: 'Inter',
                              color: textColor,
                              fontWeight: FontWeight.w400)),
                    ],
                  ),
                );
              },
            ),
            Text("4.08% aujourd'hui",
                style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Inter',
                    color: greenColor,
                    fontWeight: FontWeight.w600)),
          ],
        ),
        // InkWell(
        //   onTap: () {
        //     Navigator.pushNamed(context, RouteConstants.profil);
        //   },
        //   child: Image.asset(
        //     'assets/images/user-image-with-black-background.png',
        //     height: 60,
        //   ),
        // ),
      ],
    );
  }
}
