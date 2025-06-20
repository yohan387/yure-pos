part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class LoadBalanceEvent extends TransactionEvent {}

class LoadInitialTransactionsEvent extends TransactionEvent {}

class LoadMoreTransactionsEvent extends TransactionEvent {}
