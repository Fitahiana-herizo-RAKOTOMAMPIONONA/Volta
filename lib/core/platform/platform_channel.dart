import 'package:flutter/services.dart';
import '../errors/exception.dart' as core_exceptions;

class PlatformChannel {
  static const MethodChannel _channel = MethodChannel('volta/battery_info');

  static Future<Map<String, dynamic>?> getBatteryStats() async {
    try {
      final Map<dynamic, dynamic>? result = 
          await _channel.invokeMethod('getBatteryStats');
      
      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } on PlatformException catch (e) {
      throw core_exceptions.PlatformException(e.message ?? 'Unknown platform error');
    }
  }
}