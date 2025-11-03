import 'package:todouapp/core/config/app_config.dart';
import 'package:todouapp/core/di/injection.dart';
import 'package:todouapp/features/mobile_payments/data/datasources/i_mobile_payment_data_source.dart';
import 'package:todouapp/features/mobile_payments/data/datasources/mobile_payment_mock_data_source.dart';
import 'package:todouapp/features/mobile_payments/data/datasources/mobile_payment_remote_data_source.dart';
import 'package:todouapp/features/mobile_payments/data/repositories/mobile_payment_repository_impl.dart';
import 'package:todouapp/features/mobile_payments/domain/repositories/i_mobile_payment_repository.dart';
import 'package:todouapp/features/mobile_payments/domain/usecases/init_payment.dart';
import 'package:todouapp/features/mobile_payments/domain/usecases/stripe_verify_payment.dart';
import 'package:todouapp/features/mobile_payments/domain/usecases/verify_payment.dart';
import 'package:todouapp/features/mobile_payments/presentation/bloc/mobile_payment_bloc.dart';

Future<void> setupMobilePaymentsFeature() async {
  // DATA SOURCE
  if (AppConfig.isMockMode) {
    sl.registerLazySingleton<IMobilePaymentDataSource>(
      () => MobilePaymentMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<IMobilePaymentDataSource>(
      () => MobilePaymentRemoteDataSource(apiClient: sl()),
    );
  }

  // REPOSITORY
  sl.registerLazySingleton<IMobilePaymentRepository>(
    () => PaymentRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );

  // USE CASES
  sl.registerLazySingleton(() => InitPayment(sl<IMobilePaymentRepository>()));
  sl.registerLazySingleton(
      () => VerifyPayment(sl<IMobilePaymentRepository>()));
  sl.registerLazySingleton(
      () => StripeVerifyPayment(sl<IMobilePaymentRepository>()));

  // BLOC
  sl.registerFactory(
    () => MobilePaymentBloc(
      initPayment: sl<InitPayment>(),
      verifyPayment: sl<VerifyPayment>(),
      stripeVerifyPayment: sl<StripeVerifyPayment>(),
    ),
  );
}
