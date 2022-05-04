import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:carbonvoice_audio/src/cv_audio_context.dart';
import 'package:carbonvoice_audio/src/cv_audio_player.dart';
import 'package:carbonvoice_audio/src/model/model.dart';
import 'package:carbonvoice_audio/src/model/src/recorder_state.dart';
import 'package:carbonvoice_audio/src/model/src/recorder_ui_state.dart';
import 'package:carbonvoice_audio/src/utils/src/web_utils.dart';
import 'package:carbonvoice_audio/src/utils/utils.dart';
import 'package:cv_platform_interface/cv_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart' as p_interface;
import 'package:wakelock/wakelock.dart';

class CarbonAudioRecorder {
  /// [Context]
  CarbonVoiceAudioContext context;

  /// [Internal variables]
  /// temp filePath
  late String _filePath;

  /// time Counter
  final Stopwatch _stopwatch = Stopwatch();

  /// [FlutterSound Recorder]
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  /// [Streams] and forwarders
  StreamController<RecorderUIState> recorderUIStateStreamController = StreamController<RecorderUIState>.broadcast();

  StreamController<RecorderState> recorderStateStreamController = StreamController<RecorderState>.broadcast();

  /// passthrough stream of recorder's progress
  Stream<RecordingDisposition>? onProgress;

  /// input changes
  StreamSubscription? _inputChangeStream;

  /// [Stream getters]
  Stream<RecorderUIState> get recorderUIStateStream => recorderUIStateStreamController.stream;

  ///
  Stream<RecorderState> get recorderStateStream => recorderStateStreamController.stream;

  /// [Stream value buffers]
  RecorderUIState recorderUIState = RecorderUIState();

  ///
  RecorderState recorderState = RecorderState();

  /// [Other getters]
  bool get isRecorderActive => _recorder.isRecording;

  ///
  String get filePath => _filePath;

  ///
  Stopwatch get stopwatch => _stopwatch;

  /// Stream last value getters
  // Future<RecorderUIState> get recorderUIState async {
  //   print("DEBUG: recorderUIState -> get");
  //   if (recorderUIStateStreamController.isClosed) {
  //     return RecorderUIState();
  //   } else {
  //     var v = await recorderUIStateStreamController.stream.last
  //     return ;
  //   }
  // }

  // Future<RecorderState> get recorderState async {
  //   print("DEBUG: recorderState -> get");
  //   if (recorderStateStreamController.isClosed) {
  //     return RecorderState();
  //   } else {
  //     var v = await recorderStateStreamController.stream.last;
  //     return v;
  //   }
  // }

  CarbonAudioRecorder._internal({CarbonVoiceAudioContext? allocatedContext})
      : context = allocatedContext ?? CarbonVoiceAudioContext.instance() {
    onInit();
  }

  CarbonAudioRecorder.init({CarbonVoiceAudioContext? allocatedContext})
      : this._internal(allocatedContext: allocatedContext);

  static CarbonAudioRecorder of(CarbonVoiceAudioContext context) {
    CarbonAudioRecorder recorder;
    recorder = CarbonAudioRecorder.init(allocatedContext: context);
    return recorder;
  }

  /// First method to be called
  ///
  /// Initializes streams
  @mustCallSuper
  void onInit() {
    initStreams();
  }

  ///
  @mustCallSuper
  void onRecordingStarted() {
    onProgress = _recorder.onProgress;
    initStreams();
    // Listen in on the audio stream so we can create a waveform of the audio
    onProgress!.listen((e) async {
      double? decibels = e.decibels;

      RecorderUIState uiState = recorderUIState;
      RecorderState state = recorderState;
      if (decibels! > uiState.maxDecibels) uiState.maxDecibels = decibels;
      uiState.soundSamples[uiState.ndxBars] = decibels;
      if (++uiState.ndxBars >= RecorderUIState.BARS) uiState.ndxBars = 0;

      //print("Decibels: $decibels or $maxDecibels, ${decibels / maxDecibels}");
      uiState.duration = _stopwatch.elapsed;
      uiState.setTimerCount(state);
      setUIState(RecorderUIState(
          duration: uiState.duration,
          maxDecibels: uiState.maxDecibels,
          soundSamples: uiState.soundSamples,
          ndxBars: uiState.ndxBars,
          timerCount: uiState.timerCount));
    });
  }

  ///
  @mustCallSuper
  void onRelease() async {
    stopTimer();
    await _recorder.stopRecorder();
    await setNonInterruptions(false);
    await CarbonAudioPlayer.initPlayRecordSession(activate: true);
    _inputChangeStream?.cancel();
    closeStreams();
  }

  ///
  @mustCallSuper
  void onDispose() async {
    _recorder.closeRecorder();
    context.reload();
  }

  ///
  @mustCallSuper
  void _onError(Object error) {
    print("????? AudioInput Error received: $error");
  }

  ///
  @mustCallSuper
  void _onEvent(Object? event) async {
    print("✅✅✅✅✅ AudioInput Event received: $event");
    var data = Map<String, dynamic>.from(event as Map<dynamic, dynamic>);
    context.audioRouter?.updateCurrentAudioInput();
  }

  ///
  initStreams({bool recordingStarted = false}) {
    print("DEBUG: initStreams -> started");

    recorderUIStateStreamController = StreamController<RecorderUIState>.broadcast();
    recorderStateStreamController = StreamController<RecorderState>.broadcast();
    recorderUIStateStream.listen((e) {
      recorderUIState = e;
    });
    recorderStateStream.listen((e) {
      recorderState = e;
    });
    setUIState(RecorderUIState());
    setState(RecorderState(isRecording: recordingStarted));

    print("DEBUG: initStreams -> done");
  }

  ///
  Future initRecorder() async {
    try {
      pausePlayer();
      context.reload();
      //registerInputChange();

      var success = (await context.permissions?.microphone.checkAndRequest())?.isAllowed ?? false;
      await setNonInterruptions(true);
      if (success) {
        await openRecorderSession();
        context.audioRouter?.updateCurrentAudioInput();
        onRecordingStarted();
        // Set rate that audio stream will be sampled for the sound bars
        setSubscriptionDuration(const Duration(milliseconds: 60));
        startRecording().then((value) => setState(RecorderState(isRecording: true)));
      } else {
        assert(false, 'Permission denied');
      }
    } catch (e) {
      print(e);
    }
  }

  ///
  void setUIState(RecorderUIState newState) {
    if (!recorderUIStateStreamController.isClosed && !recorderUIStateStreamController.isPaused) {
      recorderUIStateStreamController.add(newState);
    }
  }

  ///
  void setState(RecorderState newState) {
    if (!recorderStateStreamController.isClosed && !recorderStateStreamController.isPaused) {
      recorderStateStreamController.add(newState);
    }
  }

  ///
  clearState() {
    if (!recorderUIStateStreamController.isClosed && !recorderUIStateStreamController.isPaused) {
      recorderUIStateStreamController.add(RecorderUIState());
    }
    if (!recorderStateStreamController.isClosed && !recorderStateStreamController.isPaused) {
      recorderStateStreamController.add(RecorderState());
    }
    _stopwatch.reset();
  }

  ///
  void pausePlayer() {
    /*
    if (context.type == CarbonVoiceContextType.recorder) {
      context.playbackStream?.pause();
    }
    */
  }

  ///
  setSubscriptionDuration(Duration duration) {
    _recorder.setSubscriptionDuration(duration);
  }

  ///
  Future startRecording() async {
    try {
      if (!kIsWeb) {
        _filePath = await AudioFile.getFilePath("audio_message", ".wav");
        await _recorder.startRecorder(
            audioSource: p_interface.AudioSource.defaultSource,
            toStream: context.getRecorderStreamSink,
            codec: Codec.pcm16,
            sampleRate: 44100,
            bitRate: 96000);
      } else {
        final browser = Browser.detectOrNull();
        var isSafari = browser != null && browser.browser == 'Safari';
        _filePath = isSafari ? 'audio_message.mp4' : 'audio_message.webm';
        // Suported codecs: https://flutter-sound.canardoux.xyz/guides_codec.html
        await _recorder.startRecorder(
            sampleRate: 44100, bitRate: 96000, codec: isSafari ? Codec.aacMP4 : Codec.opusWebM, toFile: _filePath);
      }
      startTimer();
    } catch (e) {
      return Future.error(e);
    }
  }

  /// [Recorder actions]
  Future stopRecording() async {
    stopTimer();
    await _recorder.stopRecorder();
    await _recorder.closeRecorder();
    context.newState = AudioStateStopped();
    await setNonInterruptions(false);
    clearState();
  }

  ///
  Future stopRecorder() async {
    stopTimer();
    _recorder.stopRecorder();
    context.newState = AudioStateStopped();
    clearState();
  }

  ///
  Future pauseRecorder() async {
    stopTimer();
    context.newState = AudioStatePaused();
    await _recorder.pauseRecorder();
    setState(RecorderState(isRecording: false));
  }

  ///
  Future resumeRecorder() async {
    startTimer();
    await _recorder.resumeRecorder();
    setState(RecorderState(isRecording: true));
  }

  /// [Utils]
  FutureOr getRecordURL({required String path}) async {
    if (await context.recorderFile(_filePath) != null) {
      return await _recorder.getRecordURL(path: (await context.recorderFile(_filePath))!.path);
    } else {
      _onError(const FileSystemException('File not found'));
    }
  }

  ///
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

  ///
  Future setNonInterruptions(bool nonInterruption) async {
    if (!kIsWeb && Platform.isIOS) {
      await CarbonVoiceAudioPlatform.instance.setPrefersNoInterruptionsFromSystemAlerts(nonInterruption);
    }
  }

  ///
  Future releaseRecorder(bool openPlaySession) async {
    onRelease();
  }

  ///
  closeStreams() {
    recorderUIStateStreamController.close();
    recorderStateStreamController.close();
  }

  ///
  void startTimer() {
    print("DEBUG: TIMER -> startTimer");
    _stopwatch.start();
    Wakelock.enable();
  }

  void stopTimer() {
    print("DEBUG: TIMER -> stopTimer");
    _stopwatch.stop();
    Wakelock.disable();
  }

  ///  void registerInputChange() {
  ///    _inputChangeStream = CarbonAudioPlayer.of(context).addInputChangeListen(_onEvent, onError: _onError);
  ///  }

  ///
  Future<List<int>?> getRecordingBytes() async {
    final result = !kIsWeb ? await context.recorderBytes() : await FileUtils.getFileBytes(_filePath);
    return result?.toList();
  }
}
