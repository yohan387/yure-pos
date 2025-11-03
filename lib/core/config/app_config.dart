import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Modes d'exécution de l'application
enum AppMode {
  /// Mode mock - utilise des données fictives (pas d'appels API)
  mock,

  /// Mode production - utilise les vraies API
  prod;

  /// Convertit une chaîne en AppMode
  static AppMode fromString(String value) {
    return AppMode.values.firstWhere(
      (mode) => mode.name == value.toLowerCase(),
      orElse: () => AppMode.prod,
    );
  }
}

/// Configuration globale de l'application
/// Gère le mode d'exécution (mock/prod) basé sur la variable d'environnement APP_MODE
class AppConfig {
  static late AppMode _mode;

  /// Initialise la configuration à partir du fichier .env
  /// Doit être appelé au démarrage de l'application, après dotenv.load()
  static void initialize() {
    final modeString = dotenv.env['APP_MODE'] ?? 'prod';
    _mode = AppMode.fromString(modeString);
  }

  /// Mode actuel de l'application
  static AppMode get mode => _mode;

  /// Retourne true si l'application est en mode mock
  static bool get isMockMode => _mode == AppMode.mock;

  /// Retourne true si l'application est en mode production
  static bool get isProdMode => _mode == AppMode.prod;
}
