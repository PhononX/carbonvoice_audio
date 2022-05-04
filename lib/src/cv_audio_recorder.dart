import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:carbonvoice_audio/src/cv_audio_context.dart';
import 'package:carbonvoice_audio/src/cv_audio_player.dart';
import 'package:carbonvoice_audio/src/model/audio_file.dart';
import 'package:carbonvoice_audio/src/utils/permissions/cv_audio_permissions.dart';
import 'package:carbonvoice_audio/src/utils/web_utils.dart';
import 'package:cv_platform_interface/cv_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart' as p_interface;
import 'package:carbonvoice_audio/src/utils/file_utils.dart';
import 'package:wakelock/wakelock.dart';

class CarbonAudioRecorder {
  CarbonVoiceAudioContext context;

  final ValueNotifier<bool> _isRecording = ValueNotifier<bool>(false);

  late String _filePath;
  final _recorder = FlutterSoundRecorder();
  Stream<RecordingDisposition>? onProgress;
  late ValueNotifier<Duration> _duration = ValueNotifier<Duration>(Duration.zero);
  // max decibels heard while monitoring recording
  static double maxDecibels = 10.0;

  // How many bars should be drawn?
  static const int BARS = 5;

  // List holding decibel level for bars
  List<double> soundSamples = List.generate(BARS, (index) => 0.0, growable: false);

  // Index for next sound sample - keeps a rolling window of sound samples
  final ValueNotifier<int> ndxBars = ValueNotifier<int>(0);

  final Stopwatch _stopwatch = Stopwatch();

  StreamSubscription? _inputChangeStream;

  CarbonAudioRecorder._internal({CarbonVoiceAudioContext? allocatedContext})
      : context = allocatedContext ?? CarbonVoiceAudioContext.instance() {
    onInit();
  }

  CarbonAudioRecorder.init({CarbonVoiceAudioContext? allocatedContext})
      : this._internal(allocatedContext: allocatedContext);

  @mustCallSuper
  void onInit() {}

  @mustCallSuper
  void onRecordingStarted() {
    // Reset recording data
    soundSamples = List.generate(BARS, (index) => 0.0, growable: false);
    ndxBars.value = 0;
    maxDecibels = 10.0;
    _duration = ValueNotifier<Duration>(Duration.zero);

    onProgress = _recorder.onProgress;
    // Listen in on the audio stream so we can create a waveform of the audio
    /*_recorder.onProgress!.listen((e) {
      double? decibels = e.decibels;
      if (decibels! > maxDecibels) maxDecibels = decibels;
      soundSamples[ndxBars.value] = decibels;
      if (++ndxBars.value >= BARS) ndxBars.value = 0;

      //print("Decibels: $decibels or $maxDecibels, ${decibels / maxDecibels}");
      _duration.value = _stopwatch.elapsed;
    });
    */
  }

  @mustCallSuper
  void onRelease() {}

  void dispose() async {
    _recorder.closeRecorder();
  }

  static CarbonAudioRecorder of(CarbonVoiceAudioContext context) {
    CarbonAudioRecorder recorder;
    recorder = CarbonAudioRecorder.init(allocatedContext: context);
    return recorder;
  }

  Future initRecorder() async {
    pausePlayer();
    //registerInputChange();

    var success = (await context.permissions?.microphone.checkAndRequest())?.isAllowed ?? false;
    await setNonInterruptions(true);
    if (success) {
      await openRecorderSession();
      context.audioRouter?.updateCurrentAudioInput();
      onRecordingStarted();
      setSubscriptionDuration(const Duration(milliseconds: 60));
      startRecording();
    } else {
      assert(false, 'Permission denied');
    }
  }

  void pausePlayer() {
    /*
    if (context.type == CarbonVoiceContextType.recorder) {
      context.playbackStream?.pause();
    }
    */
  }

  setSubscriptionDuration(Duration duration) {
    _recorder.setSubscriptionDuration(duration);
  }

  Future startRecording() async {
    if (!kIsWeb) {
      _filePath = await AudioFile.getFilePath("audio_message", ".aac");
      await _recorder.startRecorder(
          audioSource: p_interface.AudioSource.defaultSource,
          toFile: _filePath,
          codec: Codec.aacADTS,
          sampleRate: 44100,
          bitRate: 96000);
    } else {
      final browser = Browser.detectOrNull();
      // Suported codecs: https://flutter-sound.canardoux.xyz/guides_codec.html
      var isSafari = browser != null && browser.browser == 'Safari';
      _filePath = isSafari ? 'audio_message.mp4' : 'audio_message.webm';
      await _recorder.startRecorder(
          sampleRate: 44100, bitRate: 96000, codec: isSafari ? Codec.aacMP4 : Codec.opusWebM, toFile: _filePath);
    }
    startTimer();
  }

  Future stopRecording() async {
    await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    await setNonInterruptions(false);
  }

  Future stopRecorder() async {
    stopTimer();
    _recorder.stopRecorder();
  }

  Future pauseRecorder() async {
    stopTimer();
    await _recorder.pauseRecorder();
  }

  Future resumeRecorder() async {
    startTimer();
    await _recorder.resumeRecorder();
  }

  Future getRecordURL({required String path}) async {
    return await _recorder.getRecordURL(path: _filePath);
  }

  Future openRecorderSession() async {
    await _recorder.openRecorder();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth | AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    session.setActive(true);
  }

  Future setNonInterruptions(bool nonInterruption) async {
    if (Platform.isIOS && !kIsWeb) {
      await CarbonVoiceAudioPlatform.instance.setPrefersNoInterruptionsFromSystemAlerts(nonInterruption);
    }
  }

  Future releaseRecorder(bool openPlaySession) async {
    onRelease();
    stopTimer();
    _recorder.stopRecorder();
    await setNonInterruptions(false);
    await CarbonAudioPlayer.initPlayRecordSession(activate: true);
    _inputChangeStream?.cancel();
  }

  void startTimer() {
    print("DEBUG: TIMER -> startTimer");
    _isRecording.value = true;
    _stopwatch.start();
    Wakelock.enable();
  }

  void stopTimer() {
    print("DEBUG: TIMER -> stopTimer");
    _isRecording.value = false;
    _stopwatch.stop();
    Wakelock.disable();
  }

  String get timerCount {
    var totalSeconds = _duration.value.inSeconds;
    var minutes = totalSeconds ~/ 60.0;
    var seconds = totalSeconds - minutes * 60;
    if (isRecording || _duration.value.inMilliseconds > 0) {
      return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    } else {
      return "--:--";
    }
  }

  ///  void registerInputChange() {
  ///    _inputChangeStream = CarbonAudioPlayer.of(context).addInputChangeListen(_onEvent, onError: _onError);
  ///  }

  void _onError(Object error) {
    print("????? AudioInput Error received: $error");
  }

  void _onEvent(Object? event) async {
    print("✅✅✅✅✅ AudioInput Event received: $event");
    var data = Map<String, dynamic>.from(event as Map<dynamic, dynamic>);
    context.audioRouter?.updateCurrentAudioInput();
  }

  bool get isRecording => _recorder.isRecording;

  int get ndxBar => ndxBars.value;

  Duration get duration => _duration.value;

  String get filePath => _filePath;

  Future<List<int>> getRecordingBytes() async {
    CarbonAudioRecorder.of(context).duration;
    if (kIsWeb) {
      var url = await _recorder.getRecordURL(path: _filePath);
      final result = await FileUtils.getFileBytes(url!);
      return result;
    } else {
      return FileUtils.getFileBytes(_filePath);
    }
  }
}
