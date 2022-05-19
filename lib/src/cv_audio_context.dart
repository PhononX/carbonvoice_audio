import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:carbonvoice_audio/cv_audio.dart';
import 'package:carbonvoice_audio/src/utils/utils.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

enum CarbonVoiceContextType { playback, recorder, both }

class CarbonVoiceAudioContext {
  /// Dynamic variables
  StreamController<Food>? _playbackStreamController;
  StreamController<Food>? _recorderStreamController;
  List<Uint8List>? _recorderBuffer;
  List<Uint8List>? _playbackBuffer;

  CarbonVoiceAudioPermissions? _permissions;
  CarbonAudioRouter? _audioRouter;

  /// Class operational variables
  final ValueNotifier<bool> _initialized = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _recording = ValueNotifier<bool>(false);
  final ValueNotifier<AudioState> _audioState = ValueNotifier<AudioState>(AudioStateNone());
  final CarbonVoiceContextType type;

  /// Sinbleton variables
  static CarbonVoiceAudioContext? _instance = CarbonVoiceAudioContext._internal();

  CarbonVoiceAudioContext._internal({this.type = CarbonVoiceContextType.both}) {
    Future.sync(onInit);
  }
  CarbonVoiceAudioContext.protected({type = CarbonVoiceContextType.both}) : this._internal(type: type);

  factory CarbonVoiceAudioContext.instance() {
    if ((_instance?.isInitialized ?? false) == false) {
      _instance = CarbonVoiceAudioContext._internal(type: CarbonVoiceContextType.both);
      return _instance!;
    }
    return _instance!;
  }

  List<Uint8List>? get recorderBuffer => _recorderBuffer;

  List<Uint8List>? get playbackBuffer => _playbackBuffer;

  Stream<Food>? get getPlaybackStream => _playbackStreamController?.stream;

  Stream<Food>? get getRecorderStream => _playbackStreamController?.stream;

  StreamSink<Food>? get getPlaybackStreamSink => _playbackStreamController?.sink;

  StreamSink<Food>? get getRecorderStreamSink => _recorderStreamController?.sink;

  CarbonVoiceAudioPermissions? get permissions => _permissions;

  CarbonAudioRouter? get audioRouter => _audioRouter;

  bool get isInitialized => _initialized.value;

  bool get isRecording => _audioState.value.isRecording;

  AudioState get audioState => _audioState.value;

  set newState(AudioState state) => _audioState.value = state;

  @mustCallSuper
  onInit() => Future.wait([_initStreams(type), _loadPermissions(), _loadAudioRouter()])
      .then((value) => _initialized.value = true);

  @mustCallSuper
  onDispose() {
    if (_playbackStreamController != null) {
      _clearRecorderStream();
    }
    if (_recorderStreamController != null) {
      _clearPlaybackStream();
    }

    _initialized.value = false;
    _recording.value = false;
  }

  Future<bool> _loadPermissions() async {
    _permissions = await CarbonVoiceAudioPermissions.check();
    return true;
  }

  Future<bool> _loadAudioRouter() async {
    _audioRouter = await CarbonAudioRouter.load();
    return true;
  }

  FutureOr<Uint8List?> _toWaveBytes(Uint8List bytes, {int sampleRate = 44100}) async {
    var _input_path = await AudioFile.getFilePath("audio_input", ".raw");
    var _output_path = await AudioFile.getFilePath("audio_output", ".wav");
    File file = File(_input_path)..writeAsBytesSync(bytes);
    final result = await FFmpegKit.execute('-f s16le -ar 44100 -i ${_input_path} ${_output_path}');
    final returnCode = await result.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      var bytes = File(_output_path).readAsBytesSync();
      print('===========');
      var original = base64.encode(file.readAsBytesSync());
      print(original);
      print('===========');
      var converted = base64.encode(bytes);
      print(converted);
      return bytes;
    } else if (ReturnCode.isCancel(returnCode)) {
      // CANCEL
      return null;
    } else {
      // The stack trace if FFmpegKit fails to run a command
      final failStackTrace = await result.getFailStackTrace();

      // The list of logs generated for this execution
      final logs = await result.getLogs();
      return null;
    }
  }

  FutureOr<Uint8List?> _toAAC_ADTC(Uint8List bytes, {int sampleRate = 44100}) async {
    var _input_path = await AudioFile.getFilePath("audio_message", ".raw");
    var _output_path = await AudioFile.getFilePath("audio_message", ".aac");
    File file = File(_input_path)..writeAsBytesSync(bytes);
    final result = await FFmpegKit.execute('-f s16be -ar 44100 -b:v 96K -i ${_input_path} ${_output_path}');
    final returnCode = await result.getReturnCode();
    if (ReturnCode.isSuccess(returnCode)) {
      return File(_output_path).readAsBytesSync();
    } else if (ReturnCode.isCancel(returnCode)) {
      // CANCEL
      return null;
    } else {
      // The stack trace if FFmpegKit fails to run a command
      final failStackTrace = await result.getFailStackTrace();

      // The list of logs generated for this execution
      final logs = await result.getLogs();
      return null;
    }
  }

  FutureOr<Uint8List?> recorderBytes({bool wave = true}) async {
    if (_recorderBuffer != null && (_recorderBuffer?.length ?? 0) > 0) {
      var buffer = _recorderBuffer!.reduce((a, b) => Uint8List.fromList((a.toList() + b.toList())));
      return wave ? await _toWaveBytes(buffer) : await _toAAC_ADTC(buffer);
    } else {
      return null;
    }
  }

  FutureOr<Uint8List?> playbackBytes({bool wave = false}) async {
    if (_playbackBuffer != null && (_playbackBuffer?.length ?? 0) > 0) {
      var buffer = _playbackBuffer!.reduce((a, b) => Uint8List.fromList((a.toList() + b.toList())));
      return wave ? buffer : await _toWaveBytes(buffer);
    } else {
      return null;
    }
  }

  reload() {
    switch (type) {
      case CarbonVoiceContextType.playback:
        _reopenPlaybackStream();
        break;
      case CarbonVoiceContextType.recorder:
        _reopenRecorderStream();
        break;
      case CarbonVoiceContextType.both:
        _reopenPlaybackStream();
        _reopenRecorderStream();

        break;
    }
  }

  Future<bool> _initStreams(CarbonVoiceContextType _type) async {
    switch (_type) {
      case CarbonVoiceContextType.playback:
        _initPlaybackStream();
        break;
      case CarbonVoiceContextType.recorder:
        _initRecorderkStream();
        break;
      case CarbonVoiceContextType.both:
        _initPlaybackStream();
        _initRecorderkStream();
        break;
    }
    return true;
  }

  void _clearPlaybackStream() {
    _playbackStreamController?.close();
    _playbackStreamController = null;
    _recorderBuffer = <Uint8List>[];
  }

  void _clearRecorderStream() {
    _recorderStreamController?.close();
    _recorderStreamController = null;
    _recorderBuffer = <Uint8List>[];
  }

  void _initPlaybackStream() {
    _playbackStreamController = StreamController<Food>.broadcast();
    _playbackBuffer = <Uint8List>[];
    _playbackStreamController?.stream
        .listen((event) => (event as FoodData).data != null ? _playbackBuffer?.add(event.data!) : null);
  }

  void _initRecorderkStream() {
    _recorderStreamController = StreamController<Food>.broadcast();
    _recorderBuffer = <Uint8List>[];
    _recorderStreamController?.stream.listen((event) {
      if ((event as FoodData).data != null) {
        _recorderBuffer?.add(event.data!);
      }
    });
  }

  void _reopenPlaybackStream() {
    _playbackStreamController?.close();
    _initPlaybackStream();
  }

  void _reopenRecorderStream() {
    _recorderStreamController?.close();
    _initRecorderkStream();
  }

  //void _disposePlaybackSession
}
