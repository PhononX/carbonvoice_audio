import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:carbonvoice_audio/src/router/router.dart';
import 'package:cv_platform_interface/cv_platform_interface.dart';
import 'package:flutter/foundation.dart';

class CarbonAudioRouter extends CarbonAudioRouterInterface {
  CarbonAudioRouter({AudioInput? audioInput}) : super(audioInput: audioInput);

  static Future<CarbonAudioRouter> load() async {
    return await CarbonAudioRouter()
      ..loadCurrentAudioInput();
  }

  @override
  FutureOr<AudioInput> loadCurrentAudioInput() async {
    if (!(kIsWeb || !Platform.isIOS)) {
      late AudioInput _tempInput;
      AVAudioSession avSession = AVAudioSession();
      var current = await avSession.currentRoute;
      print("loadCurrentAudioInput ${current.inputs} len: ${current.inputs.length}");
      if (current.inputs.isNotEmpty) {
        for (var port in current.inputs) {
          print("loadCurrentAudioInput port ${port.portType.toString()}");
          _tempInput = AudioInput(name: port.portName, port: port.portType.toString());
        }
        return _tempInput;
      }
    }
    return AudioInput.none;
  }
}
