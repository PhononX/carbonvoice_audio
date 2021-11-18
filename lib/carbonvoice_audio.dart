import 'dart:async';

import 'package:flutter/services.dart';

class CarbonvoiceAudio {
  static const MethodChannel _channel = MethodChannel('carbonvoice_audio');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String?> sampleMethodWithArgument(String argument) async {
    final String? sampleMethodWithArgument =
        await _channel.invokeMethod('sampleMethodWithArgument', {'argumentName': argument});
    return sampleMethodWithArgument;
  }
}
