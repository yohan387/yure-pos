import 'package:todouapp/core/config/app_config.dart';
import 'package:todouapp/core/di/injection.dart';
import 'package:todouapp/features/profil/data/datasources/i_profil_data_source.dart';
import 'package:todouapp/features/profil/data/datasources/profil_mock_data_source.dart';
import 'package:todouapp/features/profil/data/datasources/profil_remote_data_source.dart';
import 'package:todouapp/features/profil/data/repositories/profil_repository_impl.dart';
import 'package:todouapp/features/profil/domain/repositories/i_profil_repository.dart';
import 'package:todouapp/features/profil/domain/usecases/get_profil.dart';
import 'package:todouapp/features/profil/presentation/bloc/profil_bloc.dart';

Future<void> setupProfilFeature() async {
  // DATA SOURCE
  if (AppConfig.isMockMode) {
    sl.registerLazySingleton<IProfilDataSource>(() => ProfilMockDataSource());
  } else {
    sl.registerLazySingleton<IProfilDataSource>(
      () => ProfilRemoteDataSource(apiClient: sl()),
    );
  }

  // REPOSITORY
  sl.registerLazySingleton<IProfilRepository>(
    () => ProfilRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );

  // USE CASES
  sl.registerLazySingleton(() => GetProfil(sl<IProfilRepository>()));

  // BLOC
  sl.registerFactory(() => ProfilBloc(getProfil: sl<GetProfil>()));
}
