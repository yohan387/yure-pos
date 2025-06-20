import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todouapp/features/transactions/data/models/transaction_model.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/amout_format.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSucces = transaction.status == 'succeeded';
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

    return ListTile(
      leading: transaction.paymentMethod.toUpperCase() == 'CARD'
          ? Image.asset(
              height: 70,
              transaction.network.toUpperCase() == "MASTERCARD"
                  ? "assets/images/mastercard.png"
                  : transaction.network.toUpperCase() == "VISA"
                      ? "assets/images/visa.png"
                      : "assets/images/visa.png",
              fit: BoxFit.contain,
            )
          : Image.asset(
              height: 70,
              transaction.network == "OM"
                  ? "assets/images/orange.png"
                  : transaction.network == "MTN"
                      ? "assets/images/momo.png"
                      : transaction.network == "MOOV"
                          ? "assets/images/moov.png"
                          : transaction.network == "WAVE"
                              ? "assets/images/wave.png"
                              : "assets/images/wallet.png",
              fit: BoxFit.contain,
            ),
      title: Text(transaction.customerPhone,
          style: TextStyle(
              fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600)),
      subtitle: Text(
          dateFormat.format(
            transaction.date,
          ),
          style: TextStyle(
              color: greyColor,
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600)),
      trailing: Text(
        '${isSucces ? '+' : '-'}${AmountFormatter.format(transaction.amount)} ${transaction.currency}',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: isSucces ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
