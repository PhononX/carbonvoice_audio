import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class CarbonAudioPlayer extends BaseAudioHandler
    with
        QueueHandler, // mix in default queue callback implementations
        SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  Stream<dynamic>? _audioInputStream;

  @override
  CarbonAudioPlayer() {
    initPlayRecordSession(activate: true);
    registerInputChange();
  }

  /// [Player actions]
  Future<void> play() {
    print("MESSAGE AUDIO HANDLER PLAY");
    Set<MediaAction> actions = {MediaAction.seek};
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      updatePosition: _player.position,
      systemActions: actions,
      controls: getControls(true),
    ));
    return _player.play();
  }

  ///
  Future<void> pause({bool hideControls = false}) {
    print("MESSAGE AUDIO HANDLER PAUSE");
    Set<MediaAction> actions = {MediaAction.seek};
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      updatePosition: _player.position,
      systemActions: actions,
      controls: hideControls ? [] : getControls(false),
    ));
    return _player.pause();
  }

  ///
  Future<void> stop({bool hideControls = false}) async {
    print("MESSAGE AUDIO HANDLER STOP");
    Set<MediaAction> actions = {MediaAction.seek};
    playbackState.add(playbackState.value.copyWith(
      processingState: AudioProcessingState.idle,
      updatePosition: _player.position,
      systemActions: actions,
      controls: hideControls ? [] : getControls(false),
    ));
    return _player.stop();
  }

  ///
  Future<void> skipToNext() async {
    print("MESSAGE AUDIO HANDLER NEXT");
  }

  ///
  Future<void> skipToPrevious() async {
    print("MESSAGE AUDIO HANDLER PREV");
  }

  ///
  Future<void> setSpeedWithMedia(double speed, MediaItem? sourceMedia) {
    if (sourceMedia != null) {
      mediaItem.add(sourceMedia);
    }
    return _player.setSpeed(speed);
  }

  ///
  Future<void> seek(Duration position) {
    print("MESSAGE AUDIO HANDLER seek: ${position.inMilliseconds}");
    return _player.seek(position);
  }

  ///
  Future<void> seekBackward(bool begin) {
    print("MESSAGE AUDIO HANDLER seekBackward: $begin");
    var position = _player.position.inMilliseconds - (10 * 1000);
    if (position < 0) {
      position = 0;
    }
    return _player.seek(Duration(milliseconds: position));
  }

  ///
  Future<void> seekForward(bool begin) {
    print("MESSAGE AUDIO HANDLER seekForward $begin");
    var position = _player.position.inMilliseconds + (5 * 1000);
    if (position > (_player.duration?.inMilliseconds ?? 0)) {
      position = _player.duration?.inMilliseconds ?? 0;
    }
    return _player.seek(Duration(milliseconds: position));
  }

  ///
  Future<void> skipToQueueItem(int i) async {
    print("skipToQueueItem: $i");
  }

  ///
  List<MediaControl> getControls(bool play) {
    return [
      MediaControl.rewind,
      play ? MediaControl.pause : MediaControl.play,
      MediaControl.fastForward,
    ];
  }

  Future<void> setAudioSource(UriAudioSource uri,
      {Duration? initialPosition, MediaItem? sourceMedia, double speed = 1.0}) {
    playbackState.add(playbackState.value.copyWith(
        controls: [MediaControl.play],
        updatePosition: _player.position,
        processingState: AudioProcessingState.loading,
        speed: speed));

    if (sourceMedia != null) {
      mediaItem.add(sourceMedia);
    }
    _player.setSpeed(speed);
    return _player.setAudioSource(uri, initialPosition: initialPosition);
  }

  ///
  Duration getPosition() {
    return _player.position;
  }

  ///
  ProcessingState getProcessingState() {
    return _player.processingState;
  }

  ///
  Stream<Duration?> getDurationStream() {
    return _player.durationStream;
  }

  ///
  Stream<PlaybackEvent> getPlaybackEventStream() {
    return _player.playbackEventStream;
  }

  ///
  void onPlayerStateChanged(PlayerState state) {}

  static Future initPlayRecordSession({bool activate = true}) async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth | AVAudioSessionCategoryOptions.defaultToSpeaker,
      // AVAudioSessionCategoryOptions.defaultToSpeaker, // |
      // AVAudioSessionCategoryOptions.duckOthers |
      // AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      // avAudioSessionSetActiveOptions:
      //     AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      androidWillPauseWhenDucked: true,
    ));
    if (activate) {
      await session.setActive(true);
    }
  }

  ///
  Stream<Duration> getPositionStream() {
    return _player.positionStream;
  }

  ///
  Stream<PlayerState> getPlayerStateStream() {
    return _player.playerStateStream;
  }

  ///
  void registerInputChange() {
    if (!kIsWeb && Platform.isIOS) {
      var audioChannel = EventChannel('carbonvoice_audio_event');
      _audioInputStream = audioChannel.receiveBroadcastStream();
    }
  }

  ///
  StreamSubscription? addInputChangeListen(void onData(event)?,
      {Function? onError, void onDone()?, bool? cancelOnError}) {
    return _audioInputStream?.listen(onData, onError: onError, onDone: onDone);
  }
}
