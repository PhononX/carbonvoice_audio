export 'src/cv_audio_router.dart' if (dart.library.html) 'src/cv_audio_router_web.dart';

import 'dart:async';

import 'package:carbonvoice_audio/src/model/model.dart';
import 'package:carbonvoice_audio/src/router/router.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

abstract class CarbonAudioRouterInterface {
  @protected
  ValueNotifier<AudioInput> audioInput = ValueNotifier<AudioInput>(AudioInput.none);

  CarbonAudioRouterInterface({AudioInput? audioInput}) {
    if (audioInput != null) {
      this.audioInput.value = audioInput;
    }
  }

  Future updateCurrentAudioInput() async => audioInput.value = await loadCurrentAudioInput();
  FutureOr<AudioInput> loadCurrentAudioInput() async {
    return audioInput.value = AudioInput.none;
  }

  String? getAudioInputName() {
    return audioInput.value.name;
  }
}
