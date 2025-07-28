import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/transaction_model.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/transaction_card.dart';
import '../widgets/transaction_card_shimmer.dart';

class SearchPage extends StatefulWidget {
  final List<TransactionModel> initialTransactions;
  final bool hasMore;

  const SearchPage({
    Key? key,
    required this.initialTransactions,
    required this.hasMore,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _searchController;
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Charger les transactions initiales dans le bloc
    context.read<TransactionBloc>().add(
          LoadInitialTransactionsEvent(),
        );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String keyword) {
    context.read<TransactionBloc>().add(SearchTransactionsEvent(keyword));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Transaction liste".toUpperCase(),
          style: TextStyle(
              fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,

            child: TextFormField(
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();

                _debounce = Timer(const Duration(milliseconds: 500), () {
                  if (value.trim().length >= 3) {
                    context
                        .read<TransactionBloc>()
                        .add(SearchTransactionsEvent(value.trim()));
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey.shade800)),
              ),
            ),
            // child: TextField(
            //   controller: _searchController,
            //   decoration: const InputDecoration(
            //     labelText: 'Rechercher une transaction',
            //     prefixIcon: Icon(Icons.search),
            //   ),
            //   onSubmitted: _onSearch,
            // ),
          ),
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                final transactions = state.transactions;

                if (state.status == TransactionStatus.loading &&
                    transactions.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == TransactionStatus.failure) {
                  return Center(child: Text('Erreur : ${state.errorMessage}'));
                }

                if (transactions.isEmpty) {
                  return const Center(
                      child: Text('Aucune transaction trouvée.'));
                }

                return ListView.builder(
                  padding: EdgeInsets.only(top: 15),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    // return ListTile(
                    //   title: Text('Transaction #${tx.id}'),
                    //   subtitle: Text('${tx.amount} • ${tx.date}'),
                    // );
                    return TransactionCard(transaction: tx);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// class SearchPage extends StatefulWidget {
//   final List<TransactionModel> initialTransactions;
//   final bool hasMore;
//   const SearchPage(
//       {super.key, required this.initialTransactions, required this.hasMore});

//   @override
//   State<SearchPage> createState() => _SearchPageState();
// }

// class _SearchPageState extends State<SearchPage> {
//   bool _isLoadingMore = false;
//   Timer? _loadingTimer;

//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();

//     _loadingTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         title: Text(
//           "Transaction liste".toUpperCase(),
//           style: TextStyle(
//               fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: BlocConsumer<TransactionBloc, TransactionState>(
//         listener: (context, state) {
//           // Arrêter le loading quand de nouvelles données arrivent
//           if (_isLoadingMore && state.transactions.isNotEmpty) {
//             _loadingTimer?.cancel();
//             setState(() {
//               _isLoadingMore = false;
//             });
//           }
//         },
//         builder: (context, state) {
//           final transactions = state.transactions.isNotEmpty
//               ? state.transactions
//               : widget.initialTransactions;
//           final hasMore = state.hasMore && !_isLoadingMore;

//           return Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(24), topRight: Radius.circular(24)),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 1,
//                   offset: const Offset(0, 0),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 16.0, vertical: 16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width: MediaQuery.of(context).size.width * 0.9,
//                         height: 50,
//                         child: TextFormField(
//                           onChanged: (value) {
//                             if (_debounce?.isActive ?? false)
//                               _debounce!.cancel();

//                             _debounce =
//                                 Timer(const Duration(milliseconds: 500), () {
//                               if (value.trim().length >= 3) {
//                                 context
//                                     .read<TransactionBloc>()
//                                     .add(SearchTransactionsEvent(value.trim()));
//                               }
//                             });
//                           },
//                           decoration: InputDecoration(
//                             hintText: 'Rechercher...',
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide:
//                                     BorderSide(color: Colors.grey.shade200)),
//                             focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10.0),
//                                 borderSide:
//                                     BorderSide(color: Colors.grey.shade800)),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: transactions.isEmpty
//                       ? ListView.builder(
//                           padding: EdgeInsets.zero,
//                           itemCount: 6,
//                           itemBuilder: (context, index) =>
//                               const TransactionCardShimmer(),
//                         )
//                       : NotificationListener<ScrollNotification>(
//                           onNotification: (ScrollNotification scrollInfo) {
//                             if (!_isLoadingMore &&
//                                 scrollInfo.metrics.pixels >=
//                                     scrollInfo.metrics.maxScrollExtent - 100 &&
//                                 scrollInfo is ScrollUpdateNotification) {
//                               setState(() {
//                                 _isLoadingMore = true;
//                               });

//                               _loadingTimer?.cancel();
//                               _loadingTimer =
//                                   Timer(const Duration(seconds: 10), () {
//                                 if (mounted) {
//                                   setState(() {
//                                     _isLoadingMore = false;
//                                   });
//                                 }
//                               });

//                               context
//                                   .read<TransactionBloc>()
//                                   .add(LoadMoreTransactionsEvent());
//                             }
//                             return false;
//                           },
//                           child: ListView.builder(
//                             padding: EdgeInsets.zero,
//                             itemCount: transactions.length + (hasMore ? 1 : 0),
//                             itemBuilder: (context, index) {
//                               if (index >= transactions.length) {
//                                 return Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Center(
//                                     child: _isLoadingMore
//                                         ? CircularProgressIndicator(
//                                             color: Colors.red)
//                                         : Text('No more transactions'),
//                                   ),
//                                 );
//                               }
//                               return TransactionCard(
//                                   transaction: transactions[index]);
//                             },
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
