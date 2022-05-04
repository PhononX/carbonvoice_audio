import 'package:flutter/widgets.dart';

abstract class AudioState {
  final AudioStates state = AudioStates.none;

  static AudioState changeTo(AudioStates newState) {
    switch (newState) {
      case AudioStates.none:
        return AudioStateNone();
      case AudioStates.recording:
        return AudioStateRecording();
      case AudioStates.playing:
        return AudioStatePlaying();
      case AudioStates.paused:
        return AudioStatePaused();
      case AudioStates.stopped:
        return AudioStateStopped();
      default:
        return AudioStateNone();
    }
  }

  bool isRecording = false;

  bool isPlaying = false;

  @override
  operator ==(Object other) {
    if (other is AudioState) {
      return other.state == state;
    } else if (other is AudioStates) {
      return state == other;
    }
    return false;
  }

  @override
  int get hashCode => hashValues(isRecording, isPlaying, state);
}

class AudioStateNone extends AudioState {}

class AudioStateRecording extends AudioState {
  @override
  AudioStates state = AudioStates.recording;

  @override
  bool isRecording = true;
}

class AudioStatePlaying extends AudioState {
  @override
  AudioStates state = AudioStates.playing;

  @override
  bool isPlaying = true;
}

class AudioStateBoth extends AudioState {
  @override
  AudioStates state = AudioStates.both;

  @override
  bool isPlaying = true;

  @override
  bool isRecording = true;
}

class AudioStateStopped extends AudioState {
  @override
  final AudioStates state = AudioStates.stopped;
}

class AudioStatePaused extends AudioState {
  @override
  final AudioStates state = AudioStates.paused;
}

enum AudioStates {
  none,
  recording,
  playing,
  both,
  paused,
  stopped,
  error,
}
