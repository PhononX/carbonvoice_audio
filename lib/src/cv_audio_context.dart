import 'dart:async';

import 'package:flutter/widgets.dart';

import 'cv_audio_router.dart';
import 'utils/permissions/cv_audio_permissions.dart';

enum CarbonVoiceContextType { playback, recorder, both }

class CarbonVoiceAudioContext {
  /// Dynamic variables
  Stream<dynamic>? _playbackStream;
  Stream<List<int>>? _recorderStream;
  CarbonVoiceAudioPermissions? _permissions;
  CarbonAudioRouter? _audioRouter;

  /// Class operational variables
  final ValueNotifier<bool> initialized = ValueNotifier<bool>(false);
  final CarbonVoiceContextType type;

  /// Sinbleton variables
  static CarbonVoiceAudioContext? _instance = CarbonVoiceAudioContext._internal();

  CarbonVoiceAudioContext._internal({this.type = CarbonVoiceContextType.both}) {
    Future.sync(onInit);
  }
  CarbonVoiceAudioContext.protected({type = CarbonVoiceContextType.both}) : this._internal(type: type);

  factory CarbonVoiceAudioContext.instance() {
    if (_instance == null) {
      _instance = CarbonVoiceAudioContext._internal(type: CarbonVoiceContextType.both);
      return _instance!;
    }
    return _instance!;
  }

  get playbackStream => _playbackStream;

  get recorderStream => _recorderStream;

  CarbonVoiceAudioPermissions? get permissions => _permissions;

  CarbonAudioRouter? get audioRouter => _audioRouter;

  @mustCallSuper
  Future<void> onInit() async {
    _initStreams(type);
    _permissions = await CarbonVoiceAudioPermissions.check();
    await CarbonAudioRouter.load();
    initialized.value = true;
  }

  void _initStreams(CarbonVoiceContextType _type) {
    switch (_type) {
      case CarbonVoiceContextType.playback:
        _playbackStream = _initPlaybackStream();
        break;
      case CarbonVoiceContextType.recorder:
        _recorderStream = _initRecorderkStream();
        break;
      case CarbonVoiceContextType.both:
        _playbackStream = _initPlaybackStream();
        _recorderStream = _initRecorderkStream();
        break;
    }
  }

  Stream<dynamic> _initPlaybackStream() {
    return StreamController<dynamic>().stream.asBroadcastStream();
  }

  Stream<List<int>> _initRecorderkStream() {
    return StreamController<List<int>>().stream.asBroadcastStream();
  }

  @mustCallSuper
  onDispose() {
    if (_playbackStream != null) {
      _playbackStream?.drain();
    }
    if (_recorderStream != null) {
      _recorderStream?.drain();
    }

    initialized.value = false;
  }

  //void _disposePlaybackSession
}
