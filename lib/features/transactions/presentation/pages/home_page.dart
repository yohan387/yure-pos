import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:todouapp/core/widgets/custom_snackbar.dart';
import 'package:todouapp/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:todouapp/features/transactions/presentation/widgets/balance_card.dart';
import 'package:todouapp/features/transactions/presentation/widgets/ho_header.dart';
import 'package:todouapp/features/transactions/presentation/widgets/transactions_bottom_sheet.dart';

import '../../../../core/constants/gateway_list.dart';
import '../widgets/ho_header_shimmer.dart';
import '../widgets/payment_gateway.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadBalanceEvent());
    context.read<TransactionBloc>().add(LoadInitialTransactionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state.status == TransactionStatus.failure) {
            CustomSnackbar.showError(
                context, state.errorMessage ?? 'Unknown error');
          }
          if (state.cancellationStatus == CancellationStatus.loading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => Center(
                child: SpinKitThreeBounce(color: Colors.red),
              ),
            );
          } else if (state.cancellationStatus == CancellationStatus.success ||
              state.cancellationStatus == CancellationStatus.failure) {
            Navigator.of(context, rootNavigator: true).pop();
            if (state.cancellationStatus == CancellationStatus.success) {
              CustomSnackbar.showSuccess(
                  context, 'Transaction annulée avec succès');
            } else if (state.cancellationStatus == CancellationStatus.failure) {
              CustomSnackbar.showError(
                  context, state.errorMessage ?? 'Échec de l\'annulation');
            }
            context.read<TransactionBloc>().add(LoadInitialTransactionsEvent());
          }
        },
        child: Stack(
          children: [
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 55),
                  child: state.balance != null
                      ? HoHeader(balance: state.balance!)
                      : const HoHeaderShimmer(),
                );
              },
            ),
            Positioned(
              top: 160,
              right: 0,
              left: 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    BalanceCard(),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(
                        height: 120,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: gatewayList
                                .map((story) =>
                                    PaymentGateway(gatewayModel: story))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 180),
                  ],
                ),
              ),
            ),
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: TransactionsBottomSheet(
                    initialTransactions: state.transactions,
                    hasMore: state.hasMore,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
