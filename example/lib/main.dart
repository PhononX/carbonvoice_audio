import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:carbonvoice_audio/carbonvoice_audio.dart';

import '../../lib/carbonvoice_audio.dart';
import '../../lib/carbonvoice_audio.dart';

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
    Map<Object?, Object?> result = await CarbonvoiceAudio.playPlayer(
        "https://www.kozco.com/tech/piano2.wav", 1.0, 0.0);

    setState(() {
      _result = result.toString();
    });
  }

  Future<void> startRecording() async {
    if (!mounted) return;

    // Set session category
    await CarbonvoiceAudio.setSessionCategory("playAndRecord");

    // Set session active
    await CarbonvoiceAudio.setSessionActive(true);

    // Check recording permissions
    String? recordPermissionState =
        await CarbonvoiceAudio.getRecordPermissionState;

    if (recordPermissionState == "granted") {

      // Try to start recording
      Map<Object?, Object?> startRecordingSessionResult =
          await CarbonvoiceAudio.startRecordingSession;

      if (startRecordingSessionResult.containsKey("success")) {
        // Recording...
        setState(() {
          _result = "Recording...";
        });
      }
    } else {
      // Request recording permission
      Map<Object?, Object?> requestRecordPermissionResult =
          await CarbonvoiceAudio.requestRecordPermission;

      if (requestRecordPermissionResult.containsKey("success")) {

        // Try to start recording
        Map<Object?, Object?> startRecordingSessionResult =
            await CarbonvoiceAudio.startRecordingSession;

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

    Map<Object?, Object?> endRecordingSessionResult = await CarbonvoiceAudio.endRecordingSession;

    setState(() {
      _result = endRecordingSessionResult.toString();;
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
