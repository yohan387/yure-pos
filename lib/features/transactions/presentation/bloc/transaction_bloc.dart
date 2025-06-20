import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todouapp/features/transactions/domain/usecases/get_balance.dart';
import 'package:todouapp/features/transactions/domain/usecases/get_transactions.dart';

import '../../data/models/balance_model.dart';
import '../../data/models/transaction_model.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetBalance getBalance;
  final GetTransactions getTransactions;

  TransactionBloc({
    required this.getBalance,
    required this.getTransactions,
  }) : super(const TransactionState()) {
    on<LoadBalanceEvent>(_onLoadBalance);
    on<LoadInitialTransactionsEvent>(_onLoadInitialTransactions);
    on<LoadMoreTransactionsEvent>(_onLoadMoreTransactions);
  }

  Future<void> _onLoadBalance(
    LoadBalanceEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    final result = await getBalance();

    result.fold(
      (failure) => emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: failure.message,
      )),
      (balance) => emit(state.copyWith(
        status: TransactionStatus.success,
        balance: balance,
      )),
    );
  }

  Future<void> _onLoadInitialTransactions(
    LoadInitialTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    final result = await getTransactions(Params(page: 1, limit: 10));

    result.fold(
      (failure) => emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: response.transactions,
        hasMore: response.hasMore,
        currentPage: response.page,
      )),
    );
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactionsEvent event,
    Emitter<TransactionState> emit,
  ) async {
    if (!state.hasMore || state.status == TransactionStatus.loadingMore) return;

    emit(state.copyWith(status: TransactionStatus.loadingMore));

    final nextPage = state.currentPage + 1;
    final result = await getTransactions(Params(page: nextPage, limit: 10));
    log('blocansactions...$result');

    result.fold(
      (failure) => emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: failure.message,
      )),
      (response) => emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: [...state.transactions, ...response.transactions],
        hasMore: response.hasMore,
        currentPage: response.page,
      )),
    );
  }
}
