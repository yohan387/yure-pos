import 'package:todouapp/core/config/app_config.dart';
import 'package:todouapp/core/di/injection.dart';
import 'package:todouapp/features/auth/data/datasources/auth_mock_data_source.dart';
import 'package:todouapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:todouapp/features/auth/data/datasources/i_auth_data_source.dart';
import 'package:todouapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:todouapp/features/auth/domain/usecases/get_merchant_terminals.dart';
import 'package:todouapp/features/auth/domain/usecases/login_with_email.dart';
import 'package:todouapp/features/auth/domain/usecases/resend_email_otp.dart';
import 'package:todouapp/features/auth/domain/usecases/verify_code.dart';
import 'package:todouapp/features/auth/domain/usecases/verify_email_otp.dart';
import 'package:todouapp/features/auth/domain/usecases/verify_otp.dart';
import 'package:todouapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:todouapp/features/auth/presentation/cubit/email_login_cubit.dart';
import 'package:todouapp/features/auth/presentation/cubit/email_otp_cubit.dart';
import 'package:todouapp/features/auth/presentation/cubit/pin_cubit.dart';
import 'package:todouapp/features/auth/presentation/cubit/terminal_selection_cubit.dart';
import 'package:todouapp/features/auth/presentation/cubit/verify_email_otp_cubit.dart';
import 'package:todouapp/features/auth/data/datasources/i_pin_local_data_source.dart';
import 'package:todouapp/features/auth/data/datasources/pin_local_data_source.dart';
import 'package:todouapp/features/auth/data/repositories/pin_repository_impl.dart';
import 'package:todouapp/features/auth/domain/repositories/i_pin_repository.dart';
import 'package:todouapp/features/auth/domain/usecases/delete_pin.dart';
import 'package:todouapp/features/auth/domain/usecases/get_pin_status.dart';
import 'package:todouapp/features/auth/domain/usecases/save_pin.dart';
import 'package:todouapp/features/auth/domain/usecases/set_pin_setup_skipped.dart';
import 'package:todouapp/features/auth/domain/usecases/verify_pin.dart';
import 'package:todouapp/features/auth/presentation/cubit/pin_state.dart';
import 'package:todouapp/core/utils/secure_storage.dart';

/// Setup des dépendances pour la feature Auth
/// Enregistre: DataSource (Mock/Remote) → Repository → UseCases → Bloc
Future<void> setupAuthFeature() async {
  // ===== DATA SOURCE =====
  // Choix entre Mock et Remote selon le mode configuré
  if (AppConfig.isMockMode) {
    sl.registerLazySingleton<IAuthDataSource>(
      () => AuthMockDataSource(),
    );
  } else {
    sl.registerLazySingleton<IAuthDataSource>(
      () => AuthRemoteDataSource(apiClient: sl()),
    );
  }

  // ===== REPOSITORY =====
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      dataSource: sl<IAuthDataSource>(),
      networkInfo: sl(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  // ===== USE CASES =====
  sl.registerLazySingleton(
    () => VerifyCode(sl<IAuthRepository>()),
  );

  sl.registerLazySingleton(
    () => VerifyOtp(sl<IAuthRepository>()),
  );

  sl.registerLazySingleton(
    () => LoginWithEmail(sl<IAuthRepository>()),
  );

  sl.registerLazySingleton(
    () => ResendEmailOtp(sl<IAuthRepository>()),
  );

  sl.registerLazySingleton(
    () => VerifyEmailOtp(sl<IAuthRepository>()),
  );

  sl.registerLazySingleton(
    () => GetMerchantTerminals(sl<IAuthRepository>()),
  );

  // ===== PIN DATA SOURCE =====
  sl.registerLazySingleton<IPinLocalDataSource>(
    () => PinLocalDataSource(sl<SecureStorageService>()),
  );

  // ===== PIN REPOSITORY =====
  sl.registerLazySingleton<IPinRepository>(
    () => PinRepositoryImpl(sl<IPinLocalDataSource>()),
  );

  // ===== PIN USE CASES =====
  sl.registerLazySingleton(
    () => SavePin(sl<IPinRepository>()),
  );

  sl.registerLazySingleton(
    () => SetPinSetupSkipped(sl<IPinRepository>()),
  );

  sl.registerLazySingleton(
    () => VerifyPin(sl<IPinRepository>()),
  );

  sl.registerLazySingleton(
    () => GetPinStatus(sl<IPinRepository>()),
  );

  sl.registerLazySingleton(
    () => DeletePin(sl<IPinRepository>()),
  );

  // ===== BLOC =====
  sl.registerFactory(
    () => AuthBloc(
      verifyCode: sl<VerifyCode>(),
      verifyOtp: sl<VerifyOtp>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  // ===== CUBIT =====
  sl.registerFactory(
    () => EmailLoginCubit(
      loginWithEmail: sl<LoginWithEmail>(),
    ),
  );

  sl.registerFactory(
    () => EmailOtpCubit(
      resendEmailOtp: sl<ResendEmailOtp>(),
    ),
  );

  sl.registerFactory(
    () => VerifyEmailOtpCubit(
      verifyEmailOtp: sl<VerifyEmailOtp>(),
    ),
  );

  sl.registerFactory(
    () => TerminalSelectionCubit(
      getMerchantTerminals: sl<GetMerchantTerminals>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  sl.registerFactoryParam<PinCubit, PinMode, void>(
    (mode, _) => PinCubit(
      savePin: sl<SavePin>(),
      setPinSetupSkipped: sl<SetPinSetupSkipped>(),
      verifyPin: mode == PinMode.verify ? sl<VerifyPin>() : null,
      deletePin: mode == PinMode.verify ? sl<DeletePin>() : null,
      secureStorage: mode == PinMode.verify ? sl<SecureStorageService>() : null,
      mode: mode,
    ),
  );
}
