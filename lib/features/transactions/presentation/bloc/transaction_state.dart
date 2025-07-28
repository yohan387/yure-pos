part of 'transaction_bloc.dart';

enum TransactionStatus { initial, loading, success, failure, loadingMore }

enum CancellationStatus { initial, loading, success, failure }

class TransactionState extends Equatable {
  final TransactionStatus status;
  final BalanceModel? balance;
  final List<TransactionModel> transactions;
  final bool hasMore;
  final int currentPage;
  final String? errorMessage;
  final CancellationStatus cancellationStatus;
  final String? cancellationErrorMessage;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.balance,
    this.transactions = const [],
    this.hasMore = true,
    this.currentPage = 1,
    this.errorMessage,
    this.cancellationStatus = CancellationStatus.initial,
    this.cancellationErrorMessage,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    BalanceModel? balance,
    List<TransactionModel>? transactions,
    bool? hasMore,
    int? currentPage,
    String? errorMessage,
    CancellationStatus? cancellationStatus,
    String? cancellationErrorMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      errorMessage: errorMessage ?? this.errorMessage,
      cancellationStatus: cancellationStatus ?? this.cancellationStatus,
      cancellationErrorMessage:
          cancellationErrorMessage ?? this.cancellationErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        balance,
        transactions,
        hasMore,
        currentPage,
        errorMessage,
        cancellationStatus,
        cancellationErrorMessage,
      ];
}
