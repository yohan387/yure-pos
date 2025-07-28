import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/core/constants/colors.dart';
import 'package:todouapp/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:todouapp/features/transactions/presentation/widgets/transaction_card.dart';

import '../../data/models/transaction_model.dart';
import '../pages/search_page.dart';
import 'transaction_card_shimmer.dart';

class TransactionsBottomSheet extends StatefulWidget {
  final List<TransactionModel> initialTransactions;
  final bool hasMore;

  const TransactionsBottomSheet({
    Key? key,
    required this.initialTransactions,
    required this.hasMore,
  }) : super(key: key);

  @override
  _TransactionsBottomSheetState createState() =>
      _TransactionsBottomSheetState();
}

class _TransactionsBottomSheetState extends State<TransactionsBottomSheet> {
  late final DraggableScrollableController _sheetController;
  bool _isExpanded = false;
  bool _isControllerAttached = false;
  bool _isLoadingMore = false;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _sheetController.addListener(_updateSheetState);
  }

  void _updateSheetState() {
    if (_isControllerAttached) {
      setState(() {
        _isExpanded = _sheetController.size > 0.82;
      });
    }
  }

  // void _onScroll() {
  //   log('scroll load data');
  //   if (_scrollController.position.pixels ==
  //           _scrollController.position.maxScrollExtent &&
  //       !_isLoadingMore) {
  //     setState(() {
  //       _isLoadingMore = true;
  //     });

  //     // Démarrer un timer pour arrêter le loading après 10 secondes
  //     _loadingTimer = Timer(const Duration(seconds: 10), () {
  //       if (mounted) {
  //         setState(() {
  //           _isLoadingMore = false;
  //         });
  //       }
  //     });

  //     context.read<TransactionBloc>().add(LoadMoreTransactionsEvent());
  //   }
  // }

  Future<void> _expandSheet() async {
    if (!_isControllerAttached) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!_isControllerAttached) return;
    }

    try {
      await _sheetController.animateTo(
        _isExpanded ? 0.82 : 0.82,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      debugPrint('Error animating sheet: $e');
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        // Arrêter le loading quand de nouvelles données arrivent
        if (_isLoadingMore && state.transactions.isNotEmpty) {
          _loadingTimer?.cancel();
          setState(() {
            _isLoadingMore = false;
          });
        }
      },
      builder: (context, state) {
        final transactions = state.transactions.isNotEmpty
            ? state.transactions
            : widget.initialTransactions;
        final hasMore = state.hasMore && !_isLoadingMore;

        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            _updateSheetState();
            return true;
          },
          child: DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.82,
            minChildSize: 0.3,
            maxChildSize: 0.82,
            // snap: true, // Optionnel: permet un snap aux tailles intermédiaires
            // snapSizes: const [0.2, 0.82, 0.82], // Positions de snap
            builder: (context, scrollController) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _isControllerAttached = true;
                  });
                }
              });

              return Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 1,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Icone drag handle cliquable
                    GestureDetector(
                      onTap: _expandSheet,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          height: 5,
                          width: 150,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Transactions récentes',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          TextButton(
                            // onPressed: _expandSheet,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchPage(
                                            initialTransactions:
                                                widget.initialTransactions,
                                            hasMore: widget.hasMore,
                                          )));
                            },
                            child: const Text('Voir plus'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: transactions.isEmpty
                          ? ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: 6,
                              itemBuilder: (context, index) =>
                                  const TransactionCardShimmer(),
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (!_isLoadingMore &&
                                    scrollInfo.metrics.pixels >=
                                        scrollInfo.metrics.maxScrollExtent -
                                            100 &&
                                    scrollInfo is ScrollUpdateNotification) {
                                  log('Chargement de plus de transactions...');
                                  setState(() {
                                    _isLoadingMore = true;
                                  });

                                  _loadingTimer?.cancel();
                                  _loadingTimer =
                                      Timer(const Duration(seconds: 10), () {
                                    if (mounted) {
                                      setState(() {
                                        _isLoadingMore = false;
                                      });
                                    }
                                  });

                                  context
                                      .read<TransactionBloc>()
                                      .add(LoadMoreTransactionsEvent());
                                }
                                return false;
                              },
                              child: ListView.builder(
                                controller: scrollController,
                                padding: EdgeInsets.zero,
                                itemCount:
                                    transactions.length + (hasMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index >= transactions.length) {
                                    return Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: _isLoadingMore
                                            ? CircularProgressIndicator(
                                                color: Colors.red)
                                            : Text('No more transactions'),
                                      ),
                                    );
                                  }
                                  return TransactionCard(
                                      transaction: transactions[index]);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
