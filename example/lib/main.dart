import 'dart:ffi';

import 'package:carbonvoice_audio/cv_audio.dart';
import 'package:cv_platform_interface/cv_platform_interface.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _result = 'Unknown';

  @override
  void initState() {
    super.initState();
    playPianoSound();
  }

  Future<void> playPianoSound() async {
    if (!mounted) return;

    // Play sound with url, speed (1.0, 1.5, 2.0, 3.0), position (0 -> 1)
    Map<Object?, Object?> result =
        await CarbonVoiceAudioPlatform.instance.playPlayer("https://www.kozco.com/tech/piano2.wav", 1.0, 0.0);

    setState(() {
      _result = result.toString();
    });
  }

  Future<void> startRecording() async {
    if (!mounted) return;

    // Check recording permissions
    String? recordPermissionState = await CarbonVoiceAudioPlatform.instance.getRecordPermissionState;

    if (recordPermissionState == "granted") {
      // Try to start recording
      Map<Object?, Object?> startRecordingSessionResult =
          await CarbonVoiceAudioPlatform.instance.startOrResumeRecording;

      if (startRecordingSessionResult.containsKey("success")) {
        // Recording...
        setState(() {
          _result = "Recording...";
        });
      }
    } else {
      // Request recording permission
      Map<Object?, Object?> requestRecordPermissionResult =
          await CarbonVoiceAudioPlatform.instance.requestRecordPermission;

      if (requestRecordPermissionResult.containsKey("success")) {
        // Try to start recording
        Map<Object?, Object?> startRecordingSessionResult =
            await CarbonVoiceAudioPlatform.instance.startOrResumeRecording;

        if (startRecordingSessionResult.containsKey("success")) {
          // Recording...
          setState(() {
            _result = "Recording...";
          });
        } else {
          // Failed to start recording session
          // startRecordingSessionResult["error"].toString();
          setState(() {
            _result = "Failed to start recording session";
          });
        }
      } else {
        // User denied permission
        // requestRecordPermissionResult["error"].toString();
        setState(() {
          _result = "User denied permission";
        });
      }
    }
  }

  Future<void> endRecording() async {
    if (!mounted) return;

    Map<Object?, Object?> endRecordingSessionResult = await CarbonVoiceAudioPlatform.instance.endRecordingSession;

    setState(() {
      _result = endRecordingSessionResult.toString();
      ;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Play Piano Sound: $_result\n'),
        ),
      ),
    );
  }
}
