import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todouapp/core/constants/colors.dart';
import 'package:todouapp/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:todouapp/features/transactions/presentation/widgets/transaction_card.dart';

import '../../data/models/transaction_model.dart';

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
  final _scrollController = ScrollController();
  bool _isExpanded = false;
  bool _isControllerAttached = false;
  bool _isLoadingMore = true;
  Timer? _loadingTimer;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    _scrollController.addListener(_onScroll);
    _sheetController.addListener(_updateSheetState);
  }

  void _updateSheetState() {
    if (_isControllerAttached) {
      setState(() {
        _isExpanded = _sheetController.size > 0.3;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      _loadingTimer = Timer(const Duration(seconds: 10), () {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      });

      context.read<TransactionBloc>().add(LoadMoreTransactionsEvent());
    }
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _scrollController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
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

        return GestureDetector(
          // Ce GestureDetector englobant permet le drag sur toute la surface
          behavior: HitTestBehavior.opaque,
          child: NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              _updateSheetState();
              return false; // Important: retourner false pour permettre le drag
            },
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.3,
              minChildSize: 0.1,
              maxChildSize: 0.9,
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
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Zone de drag étendue
                      InkWell(
                        onTap: () => _sheetController.animateTo(
                          0.9,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.drag_handle,
                            color: Colors.grey[400],
                            size: 30,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Recent Transactions',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (!_isExpanded)
                              TextButton(
                                onPressed: () => _sheetController.animateTo(
                                  0.9,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                ),
                                child: const Text('View All'),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: transactions.length + (hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= transactions.length) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _isLoadingMore
                                      ? const CircularProgressIndicator(
                                          color: primaryColor,
                                        )
                                      : const Text('No more transactions'),
                                ),
                              );
                            }
                            return TransactionCard(
                                transaction: transactions[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
