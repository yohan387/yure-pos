import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:todouapp/core/constants/colors.dart';
import 'package:todouapp/core/widgets/custom_snackbar.dart';
import 'package:todouapp/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:todouapp/features/transactions/presentation/widgets/ho_header.dart';
import 'package:todouapp/features/transactions/presentation/widgets/transactions_bottom_sheet.dart';

import '../../../../core/utils/route_observer.dart';
import '../widgets/ho_header_shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final bloc = context.read<TransactionBloc>();
    bloc.add(LoadBalanceEvent());
    bloc.add(LoadInitialTransactionsEvent());
  }

  @override
  void didPopNext() {
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  BuildContext? dialogContext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
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
              useRootNavigator: true,
              builder: (BuildContext ctx) {
                dialogContext = ctx;
                return const Center(
                  child: SpinKitThreeBounce(color: Colors.red),
                );
              },
            );
          } else if (state.cancellationStatus == CancellationStatus.success) {
            // Ferme le dialog de loading s'il est encore ouvert
            if (dialogContext != null) {
              Navigator.of(dialogContext!).pop();
              dialogContext = null;
            }
            CustomSnackbar.showSuccess(
                context, 'Transaction annulée avec succès');
          } else if (state.cancellationStatus == CancellationStatus.failure) {
            if (dialogContext != null) {
              Navigator.of(dialogContext!).pop();
              dialogContext = null;
            }
            CustomSnackbar.showError(
              context,
              state.cancellationErrorMessage ?? 'Échec de l\'annulation',
            );
          }
        },
        child: Stack(
          children: [
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 0),
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
                    //BalanceCard(),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 10),
                    //   child: SizedBox(
                    //     height: 120,
                    //     child: SingleChildScrollView(
                    //       scrollDirection: Axis.horizontal,
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: gatewayList
                    //             .map((story) =>
                    //                 PaymentGateway(gatewayModel: story))
                    //             .toList(),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // const SizedBox(height: 180),
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
