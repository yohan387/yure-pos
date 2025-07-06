part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class LoadBalanceEvent extends TransactionEvent {}

class LoadInitialTransactionsEvent extends TransactionEvent {}

class LoadMoreTransactionsEvent extends TransactionEvent {}

class CancelTransactionEvent extends TransactionEvent {
  final String reference;

  const CancelTransactionEvent(this.reference);

  @override
  List<Object> get props => [reference];
}
