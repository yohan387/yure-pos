import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:todouapp/core/network/i_network_info.dart';

/// Implémentation de INetworkInfo
/// Vérifie la connectivité réseau en deux étapes:
/// 1. Vérification de la connexion (WiFi/Mobile Data)
/// 2. Vérification de l'accès Internet réel (ping Google)
class NetworkInfoImpl implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl(Connectivity connectivity) : _connectivity = connectivity;

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none) ||
        connectivityResult.isEmpty) {
      return false;
    }

    try {
      final result = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(Duration(seconds: 3));
      return result.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
