import 'dart:async';
import 'dart:io';

import 'package:carbonvoice_audio/src/cv_audio_context.dart';
import 'package:carbonvoice_audio/src/model/model.dart';
import 'package:carbonvoice_audio/src/recorder/src/recorder_interface.dart';
import 'package:carbonvoice_audio/src/utils/utils.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart' as p_interface;

class CarbonAudioRecorder extends RecorderInterface {
  CarbonAudioRecorder.init({CarbonVoiceAudioContext? allocatedContext})
      : super.init(allocatedContext: allocatedContext);

  static CarbonAudioRecorder of(CarbonVoiceAudioContext context) {
    CarbonAudioRecorder recorder;
    recorder = CarbonAudioRecorder.init(allocatedContext: context);
    return recorder;
  }

  @override
  Future startRecording() async {
    try {
      filePath = await AudioFile.getFilePath("audio_message", "aac");
      await recorder.startRecorder(
          audioSource: p_interface.AudioSource.defaultSource,
          toFile: filePath,
          //toStream: context.getRecorderStreamSink,
          codec: Codec.aacADTS,
          sampleRate: 44100,
          bitRate: 96000);

      startTimer();
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future<List<int>?> getRecordingBytes() async {
    final result = FileUtils.getFileBytes(filePath);
    return result;
  }
}
