import 'dart:async';

import 'package:carbonvoice_audio/src/cv_audio_context.dart';
import 'package:carbonvoice_audio/src/recorder/src/recorder_interface.dart';
import 'package:carbonvoice_audio/src/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart' as p_interface;

class CarbonAudioRecorder extends RecorderInterface {
  /// temp filePath
  late String? tempPath;

  CarbonAudioRecorder.init({CarbonVoiceAudioContext? allocatedContext})
      : super.init(allocatedContext: allocatedContext);

  static CarbonAudioRecorder of(CarbonVoiceAudioContext context) {
    CarbonAudioRecorder recorder;
    recorder = CarbonAudioRecorder.init(allocatedContext: context);
    return recorder;
  }

  @override
  void onTempPath(String? path) {
    tempPath = path;
  }

  @override
  Future startRecording() async {
    try {
      final browser = Browser.detectOrNull();
      var isSafari = browser != null && browser.browser == 'Safari';
      filePath = isSafari ? 'audio_message.mp4' : 'audio_message.webm';
      // Suported codecs: https://flutter-sound.canardoux.xyz/guides_codec.html
      await recorder.startRecorder(
          audioSource: p_interface.AudioSource.defaultSource,
          sampleRate: 44100,
          bitRate: 96000,
          codec: isSafari ? Codec.aacMP4 : Codec.opusWebM,
          toFile: filePath);
      startTimer();
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<List<int>?> getRecordingBytes() async {
    var url = tempPath;
    if (url != null) {
      final result = await FileUtils.getFileBytes(url);
      return result.toList();
    }
    return null;
  }
}
