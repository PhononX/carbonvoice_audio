import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:carbonvoice_audio/src/model/audio_input.dart';
import 'package:flutter/foundation.dart';

class CarbonAudioRouter {
  ValueNotifier<AudioInput> audioInput = ValueNotifier<AudioInput>(AudioInput.none);

  CarbonAudioRouter({required AudioInput audioInput}) {
    this.audioInput.value = audioInput;
  }

  static Future<CarbonAudioRouter> load() async {
    return CarbonAudioRouter(audioInput: await loadCurrentAudioInput());
  }

  Future updateCurrentAudioInput() async => audioInput.value = await loadCurrentAudioInput();

  static FutureOr<AudioInput> loadCurrentAudioInput() async {
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

  String? getAudioInputName() {
    return audioInput.value.name;
  }

  // TODO: implement in player
  /* 
  void registerInputChange() {
    _inputChangeStream = _audioPlayerHandler.addInputChangeListen(_onEvent, onError: _onError);
  }
  */
}
