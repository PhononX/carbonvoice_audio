import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:carbonvoice_audio/carbonvoice_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _recordPermissionState = 'Unknown';

  @override
  void initState() {
    super.initState();
    initRecordPermissionState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initRecordPermissionState() async {
    Map<String, String>? result =
        await CarbonvoiceAudio.playPlayer("https://www.kozco.com/tech/piano2.wav", 1.0, 0.0);
    // String recordPermissionState;
    // // Platform messages may fail, so we use a try/catch PlatformException.
    // // We also handle the message potentially returning null.
    // try {
    //   recordPermissionState =
    //       await CarbonvoiceAudio.recordPermissionState ?? 'Unknown permission state';
    // } on PlatformException {
    //   recordPermissionState = 'Failed to get permission state.';
    // }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _recordPermissionState = result.toString();
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
          child: Text('Record Permission State: $_recordPermissionState\n'),
        ),
      ),
    );
  }
}
