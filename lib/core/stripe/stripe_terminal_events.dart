import 'package:flutter/services.dart';

class StripeTerminalEvents {
  static const EventChannel _eventChannel =
      EventChannel('stripe_terminal_events');

  Stream<Map<String, dynamic>> get events {
    return _eventChannel.receiveBroadcastStream().cast<Map<String, dynamic>>();
  }
}
