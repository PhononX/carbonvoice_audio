// ignore_for_file: constant_identifier_names

import 'package:carbonvoice_audio/src/model/src/recorder_state.dart';

class RecorderUIState {
  RecorderUIState({
    this.maxDecibels = 10,
    this.duration = Duration.zero,
    List<double>? soundSamples,
    this.ndxBars = 0,
    this.timerCount = _TIMER_COUNT_DEFAULT,
  }) : soundSamples = soundSamples ?? List.generate(BARS, (index) => 0.0, growable: false);

  /// [Consts]
  /// how many bars should be drawn?
  static const int BARS = 5;

  static const String _TIMER_COUNT_DEFAULT = "--:--";

  /// max decibels heard while monitoring recording
  double maxDecibels;

  /// duration
  Duration duration;

  /// list holding decibel level for bars
  List<double> soundSamples;

  /// index for next sound sample - keeps a rolling window of sound samples
  int ndxBars;

  /// timeCounter
  String timerCount;

  void setTimerCount(RecorderState state) async {
    var totalSeconds = duration.inSeconds;
    var minutes = totalSeconds ~/ 60.0;
    var seconds = totalSeconds - minutes * 60;
    if (state.isRecording || duration.inMilliseconds > 0) {
      timerCount = ("${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}");
    } else {
      timerCount = _TIMER_COUNT_DEFAULT;
    }
  }
}
