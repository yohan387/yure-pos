import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final connectivityResult = await connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return false;

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
