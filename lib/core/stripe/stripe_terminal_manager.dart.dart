import 'package:flutter/services.dart';
import 'stripe_terminal_events.dart';

class StripeTerminalManager {
  static const MethodChannel _channel = MethodChannel('stripe_terminal');
  static final StripeTerminalEvents _events = StripeTerminalEvents();

  static Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      throw Exception("Failed to initialize: ${e.message}");
    }
  }

  static Future<void> discoverReaders() async {
    try {
      await _channel.invokeMethod('discoverReaders');
    } on PlatformException catch (e) {
      throw Exception("Failed to discover readers: ${e.message}");
    }
  }

  static Future<void> connectReader(String readerId) async {
    try {
      await _channel.invokeMethod('connectReader', {'readerId': readerId});
    } on PlatformException catch (e) {
      throw Exception("Failed to connect reader: ${e.message}");
    }
  }

  static Future<Map<String, dynamic>> collectPayment(
      double amount, String currency) async {
    try {
      final result = await _channel.invokeMethod(
          'collectPayment', {'amount': amount, 'currency': currency});
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception("Payment failed: ${e.message}");
    }
  }

  static Future<void> cancelDiscovery() async {
    try {
      await _channel.invokeMethod('cancelDiscovery');
    } on PlatformException catch (e) {
      throw Exception("Failed to cancel discovery: ${e.message}");
    }
  }

  static Stream<Map<String, dynamic>> get eventStream {
    return _events.events;
  }
}
