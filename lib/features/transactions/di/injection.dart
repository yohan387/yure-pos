import 'package:todouapp/core/config/app_config.dart';
import 'package:todouapp/core/di/injection.dart';
import 'package:todouapp/features/transactions/data/datasources/i_transaction_data_source.dart';
import 'package:todouapp/features/transactions/data/datasources/transaction_mock_data_source.dart';
import 'package:todouapp/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:todouapp/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:todouapp/features/transactions/domain/repositories/i_transaction_repository.dart';
import 'package:todouapp/features/transactions/domain/usecases/get_balance.dart';
import 'package:todouapp/features/transactions/domain/usecases/get_cancel_payment.dart';
import 'package:todouapp/features/transactions/domain/usecases/get_transactions.dart';
import 'package:todouapp/features/transactions/presentation/bloc/transaction_bloc.dart';

/// Setup des dépendances pour la feature Transactions
Future<void> setupTransactionsFeature() async {
  // ===== DATA SOURCE =====
  if (AppConfig.isMockMode) {
    sl.registerLazySingleton<ITransactionDataSource>(
      () => TransactionMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<ITransactionDataSource>(
      () => TransactionRemoteDataSource(apiClient: sl()),
    );
  }

  // ===== REPOSITORY =====
  sl.registerLazySingleton<ITransactionRepository>(
    () => TransactionRepositoryImpl(
      dataSource: sl<ITransactionDataSource>(),
      networkInfo: sl(),
    ),
  );

  // ===== USE CASES =====
  sl.registerLazySingleton(() => GetBalance(sl<ITransactionRepository>()));
  sl.registerLazySingleton(() => GetTransactions(sl<ITransactionRepository>()));
  sl.registerLazySingleton(
      () => GetCancelPayment(sl<ITransactionRepository>()));

  // ===== BLOC =====
  sl.registerFactory(
    () => TransactionBloc(
      getBalance: sl<GetBalance>(),
      getTransactions: sl<GetTransactions>(),
      getCancelPayment: sl<GetCancelPayment>(),
    ),
  );
}
