// import 'dart:async';

// import 'package:carbon_voice_app/ui/controller/recording_controller.dart';
// import 'package:speech_to_text/speech_recognition_error.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// class TranscriptionController {
//   SpeechToText speechToText = SpeechToText();
//   final spokenWords = ''.obs;
//   bool isInitialised = false;
//   final transcriptionsList = [''].obs;
//   final isPaused = false.obs;
//   final isPartialTranscription = false.obs;
//   final partialErrorTime = 0.obs;
//   final transcriptionMap = [{}].obs;
//   final RecordingController recordingController = Get.find();
//   final speechStatus = ''.obs;

//   Future<bool> initTranscription({String printLog = ''}) async {
//     try {
//       isPaused.value = false;
//       partialErrorTime.value = 0;
//       isPartialTranscription.value = false;

//       isInitialised = await speechToText.initialize(
//         debugLogging: true,
//         onStatus: statusListener,
//         finalTimeout: Duration(milliseconds: 90),
//         onError: (SpeechRecognitionError error) {
//           print("error=======initTranscription");
//           print(error.errorMsg);
//           print(error.permanent);
//           print("error=======initTranscription");
//           if (error.permanent) {
//             isPartialTranscription.value = true;
//             partialErrorTime.value = recordingController.getDuration().inMilliseconds;
//           }
//         },
//       );
//       if (isInitialised) {
//         spokenWords.value = '';
//         transcriptionsList.value = [];
//         transcriptionMap.value = [{}];
//       }

//       if (isInitialised) {
//         await startListening();
//       } else {
//         print("Not initialised");
//       }
//       return isInitialised;
//     } catch (e) {
//       return false;
//     }
//   }

//   startListening() async {
//     if (speechToText.isNotListening) {
//       print("=-=-=-=-==- startListening1");
//       await speechToText.listen(
//         onDevice: true,
//         pauseFor: Duration(minutes: 15),
//         listenFor: Duration(minutes: 30),
//         listenMode: ListenMode.dictation,
//         partialResults: true,
//         cancelOnError: true,
//         onResult: resultHandler,
//       );
//       print("=-=-=-=-==- startListening2");
//     }
//   }

//   void statusListener(String status) {
//     speechStatus.value = status;
//     print('Received listener status: $status');
//     if (recordingController.isRecording() && status != 'listening') {
//       isPartialTranscription.value = true;
//       partialErrorTime.value = recordingController.getDuration().inMilliseconds;
//     }
//   }

//   resultHandler(SpeechRecognitionResult result) {
//     if (isPaused.value && result.finalResult) {
//       spokenWords.value = result.recognizedWords;
//       transcriptionsList.add(result.recognizedWords);
//       if (result.finalResult && !transcriptionsList.contains(result.recognizedWords)) {
//         transcriptionsList.add(result.recognizedWords);
//       }
//       List tobeRemoved = [];
//       // Removing repeated transcriptions
//       transcriptionsList.forEach((item) {
//         if (result.recognizedWords.contains(item)) {
//           tobeRemoved.add(item);
//         }
//       });

//       var lgth = 0;
//       var longest;

//       for (var i = 0; i < tobeRemoved.length; i++) {
//         if (tobeRemoved[i].length > lgth) {
//           lgth = tobeRemoved[i].length;
//           longest = tobeRemoved[i];
//         }
//       }
//       print("longest");
//       print(longest);
//       print("longest");
//       // removing the repeated transcription in the whole list
//       transcriptionsList.remove(longest);
//       if (!transcriptionsList.contains(longest)) {
//         transcriptionsList.add(longest);
//       }
//     } else {
//       if (result.isConfident()) {
//         // For creating transcription Maps with timestamps.
//         String newValue = result.recognizedWords.replaceAll(spokenWords.value, "");
//         Map intermediateSpeech = {
//           'ms': recordingController.getDuration().inMilliseconds,
//           'detected_words': newValue,
//         };
//         if (newValue != '' && newValue != result.recognizedWords) {
//           transcriptionMap.add(intermediateSpeech);
//         }
//       }

//       if (spokenWords.value == '' && result.recognizedWords != '' && recordingController.getDuration().inSeconds > 1) {
//         transcriptionsList.add(result.recognizedWords);
//       }
//       if (result.isConfident(threshold: 0.89)) {
//         transcriptionsList.remove(spokenWords.value);
//         transcriptionsList.add(result.recognizedWords);
//       }

//       spokenWords.value = result.recognizedWords;
//     }
//   }

//   pauseTranscription() async {
//     if (speechToText.isListening) {
//       isPaused.value = true;
//       await speechToText.stop();
//       print("pauseTranscription");
//     } else {
//       startListening();
//       isPaused.value = false;
//     }
//   }

//   cancelTranscription() async {
//     print("-==-=-=-=-=-cancel called");
//     //transcriptionsList.add(spokenWords.value);
//     await speechToText.cancel();
//   }
// }
