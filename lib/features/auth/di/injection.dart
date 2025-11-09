import 'package:todouapp/core/config/app_config.dart';
import 'package:todouapp/core/di/injection.dart';
import 'package:todouapp/features/auth/data/datasources/auth_mock_data_source.dart';
import 'package:todouapp/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:todouapp/features/auth/data/datasources/i_auth_data_source.dart';
import 'package:todouapp/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:todouapp/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:todouapp/features/auth/domain/usecases/login_with_email.dart';
import 'package:todouapp/features/auth/domain/usecases/verify_code.dart';
import 'package:todouapp/features/auth/domain/usecases/verify_otp.dart';
import 'package:todouapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:todouapp/features/auth/presentation/cubit/email_login_cubit.dart';
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
}
