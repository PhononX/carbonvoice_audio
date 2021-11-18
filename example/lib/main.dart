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
  String _result = 'Unknown';

  @override
  void initState() {
    super.initState();
    playPianoSound();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> playPianoSound() async {
    Map<Object?, Object?> result = await CarbonvoiceAudio.playPlayer(
        "https://www.kozco.com/tech/piano2.wav", 1.0, 0.0);
        
    if (!mounted) return;

    setState(() {
      _result = result.toString();
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
