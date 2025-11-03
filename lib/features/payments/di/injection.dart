import 'package:todouapp/core/config/app_config.dart';
import 'package:todouapp/core/di/injection.dart';
import 'package:todouapp/features/payments/data/datasources/i_stripe_payment_data_source.dart';
import 'package:todouapp/features/payments/data/datasources/stripe_payment_mock_data_source.dart';
import 'package:todouapp/features/payments/data/datasources/stripe_payment_remote_data_source.dart';
import 'package:todouapp/features/payments/data/repositories/stripe_payment_repository_impl.dart';
import 'package:todouapp/features/payments/domain/repositories/i_stripe_payment_repository.dart';
import 'package:todouapp/features/payments/domain/usescases/init_link_payment.dart';
import 'package:todouapp/features/payments/presentation/bloc/stripe_payment_bloc.dart';
import 'package:todouapp/core/utils/secure_storage.dart';

Future<void> setupPaymentsFeature() async {
  // DATA SOURCE
  if (AppConfig.isMockMode) {
    sl.registerLazySingleton<IStripePaymentDataSource>(
      () => StripePaymentMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<IStripePaymentDataSource>(
      () => StripePaymentRemoteDataSource(apiClient: sl()),
    );
  }

  // REPOSITORY
  sl.registerLazySingleton<IStripePaymentRepository>(
    () => StripePaymentRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );

  // USE CASES
  sl.registerLazySingleton(
      () => InitLinkPayment(sl<IStripePaymentRepository>()));

  // BLOC
  sl.registerFactory(
    () => StripePaymentBloc(
      repository: sl<IStripePaymentRepository>(),
      secureStorage: sl<SecureStorageService>(),
      initLinkPayment: sl<InitLinkPayment>(),
    ),
  );
}
