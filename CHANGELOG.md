## 1.1.4

* Fix missing platform check in audio player on web

## 1.1.3

* Adds models; audio_file, audio_input, audio_state
  * as well as recorder_ui_state, recorder_state
* Export policies in case we need to hide internal stuff
* Audio Context for further management of audio sessions, data flow, etc 
* Controllers
  * Recorder [cv_audio_recorder.dart](lib/src/cv_audio_recorder.dart)
  * Player same as AudioHandler [cv_audio_player.dart](lib/src/cv_audio_player.dart)
  * AudioRouter (only loads audio device info for now) [cv_audio_router.dart](lib/src/cv_audio_router.dart)
* New and old Utilities
  * permissions native/web
  * file_utils native/web
  * web specific utils

## 1.1.2

* Fix the audio input notification event

## 1.1.1

* Adds web platform

## 1.1.0

* Fixes recorder controller speech recognition

## 1.0.9

* More fixes

## 1.0.8

* Fixes typo

## 1.0.7

* Adds more business logic

## 1.0.6

* Adds setPrefersNoInterruptionsFromSystemAlerts method back

## 1.0.5

* Fixes setPrefersNoInterruptionsFromSystemAlerts method

## 1.0.4

* Adds setPrefersNoInterruptionsFromSystemAlerts method to dart

## 1.0.3

* Adds setPrefersNoInterruptionsFromSystemAlerts method

## 1.0.2

* Adds showRoutePickerView method

## 1.0.1

* Adds more examples for how to play and record

## 1.0.0

* Initial release
