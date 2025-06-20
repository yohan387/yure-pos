import 'dart:convert';
import 'dart:developer';

class TokenValidator {
  static bool isTokenValid(String? token) {
    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;

      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      final expiry = payloadMap['exp'];
      if (expiry == null) return false;

      final currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
      log('current time token $currentTime');
      log('expiry token $currentTime');

      return currentTime <= expiry;
    } catch (e) {
      return false;
    }
  }

  // static void checkTokenValidity(String? token) {
  //   if (!isTokenValid(token)) {
  //     throw TokenExpiredException();
  //   }
  // }
}
