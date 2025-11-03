import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:todouapp/core/network/api_client.dart';
import 'package:todouapp/core/network/i_network_info.dart';
import 'package:todouapp/core/network/network_info.dart';
import 'package:todouapp/core/utils/secure_storage.dart';

// Import des DI de chaque feature
import '../../features/auth/di/injection.dart' as auth_di;
import '../../features/transactions/di/injection.dart' as transactions_di;
import '../../features/profil/di/injection.dart' as profil_di;
import '../../features/mobile_payments/di/injection.dart' as mobile_payments_di;
import '../../features/payments/di/injection.dart' as payments_di;

/// Instance globale du Service Locator
final sl = GetIt.instance;

/// Point d'entrée principal pour l'injection de dépendances
/// Initialise toutes les dépendances de l'application dans l'ordre:
/// 1. Core (infrastructures de haut niveau)
/// 2. Features (par ordre de dépendances)
Future<void> setupDependencies() async {
  // ===== 1. CORE (infrastructures de haut niveau) =====
  await _setupCore();

  // ===== 2. FEATURES (par ordre alphabétique) =====
  await auth_di.setupAuthFeature();
  await mobile_payments_di.setupMobilePaymentsFeature();
  await payments_di.setupPaymentsFeature();
  await profil_di.setupProfilFeature();
  await transactions_di.setupTransactionsFeature();
}

/// Enregistrement des dépendances CORE
/// Ces dépendances sont partagées par toutes les features
Future<void> _setupCore() async {
  // ===== Secure Storage =====
  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(),
  );

  // ===== HTTP Client =====
  sl.registerLazySingleton<http.Client>(
    () => http.Client(),
  );

  // ===== API Client =====
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      client: sl<http.Client>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  // ===== Network Info =====
  sl.registerLazySingleton<Connectivity>(
    () => Connectivity(),
  );

  sl.registerLazySingleton<INetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );
}
