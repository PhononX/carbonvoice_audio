import 'dart:async';
import 'dart:html' as html;
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:carbonvoice_audio/src/model/model.dart';
import 'package:carbonvoice_audio/src/router/router.dart';
import 'package:flutter/foundation.dart';

class CarbonAudioRouter extends CarbonAudioRouterInterface {
  CarbonAudioRouter({AudioInput? audioInput}) : super(audioInput: audioInput);

  static Future<CarbonAudioRouter> load() async {
    return await CarbonAudioRouter()
      ..loadCurrentAudioInput();
  }

  @override
  FutureOr<AudioInput> loadCurrentAudioInput() async {
    const mediaStreamConstraints = {'audio': true, 'video': false};
    var deviceId = (await html.window.navigator.mediaDevices?.getUserMedia(mediaStreamConstraints))?.id;
    var devices = await html.window.navigator.mediaDevices?.enumerateDevices();

    if (deviceId != null && devices != null && devices.isNotEmpty) {
      print("loadCurrentAudioInput ${devices.toSet()} len: ${devices.length}");
      var defaultDevice = devices.reversed
          .firstWhere((element) => (element.deviceId as String) == deviceId, orElse: () => devices.first);

      return AudioInput(name: defaultDevice.label, port: defaultDevice.kind);
    }
    return AudioInput.none;
  }
}
