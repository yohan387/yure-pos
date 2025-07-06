import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todouapp/core/utils/convert_stripe_amount.dart';
import 'package:todouapp/core/widgets/button_widget.dart';
import 'package:todouapp/features/transactions/data/models/transaction_model.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/utils/amout_format.dart';
import '../bloc/transaction_bloc.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSucces = transaction.status == 'succeeded';
    final isPending = transaction.status.toLowerCase() == 'pending';
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

    return ListTile(
      onTap: () {
        Navigator.pushNamed(context, RouteConstants.paymentDetail,
            arguments: transaction);
      },
      onLongPress: () async {
        log('Long pressed on transaction: ${transaction.transactionRef}');
        if (transaction.status == 'succeeded' ||
            transaction.status == "pending") {
          showModalBottomSheet(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Date: ',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'Référence: ${transaction.transactionRef}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Montant: ',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text:
                                '${isSucces ? '+' : '-'}${AmountFormatter.format(transaction.amount)} ${transaction.currency}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: isSucces
                                  ? Colors.green
                                  : isPending
                                      ? Colors.orange
                                      : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                        text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Status: ',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: transaction.status,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: isSucces
                                ? Colors.green
                                : isPending
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ],
                    )),
                    SizedBox(height: 20),
                    if (transaction.paymentMethod.toUpperCase() == 'CARD')
                      SizedBox(
                        width: double.infinity,
                        child: BlocListener<TransactionBloc, TransactionState>(
                          listener: (context, state) {},
                          child: CustomButton(
                            text: 'Annuler la transaction',
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                              final bloc = context.read<TransactionBloc>();
                              bloc.add(CancelTransactionEvent(
                                  transaction.transactionRef));
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        }
      },
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
        transaction.paymentMethod.toUpperCase() == 'CARD'
            ? '${isSucces ? '+' : '-'}${ConvertStripeAmount.convertFromStripeAmount(transaction.amount, 'EUR')} ${transaction.currency.toUpperCase()}'
            : '${isSucces ? '+' : '-'}${AmountFormatter.format(transaction.amount)} ${transaction.currency}',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: isSucces
              ? Colors.green
              : isPending
                  ? Colors.orange
                  : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
