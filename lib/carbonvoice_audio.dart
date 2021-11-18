import 'dart:async';
import 'dart:ffi';

import 'package:flutter/services.dart';

class CarbonvoiceAudio {
  static const MethodChannel _channel = MethodChannel('carbonvoice_audio');

  // ------------------------------ Start --------------------------------------

  // Call this before any other method
  static Future<Map<Object?, Object?>> setSessionActive(bool active) async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('setSessionActive', {'active': active});
    return result;
  }


  // Test method
  static Future<String?> get getHello async {
    final String? result =
        await _channel.invokeMethod('getHello');
    return result;
  }

  // -------------------------- Session Categories -----------------------------

  /*
  /** Use this category for background sounds such as rain, car engine noise, etc.
     Mixes with other music. */
    @available(iOS 3.0, *)
    public static let ambient: AVAudioSession.Category

    /** Use this category for background sounds.  Other music will stop playing. */
    @available(iOS 3.0, *)
    public static let soloAmbient: AVAudioSession.Category

    /** Use this category for music tracks.*/
    @available(iOS 3.0, *)
    public static let playback: AVAudioSession.Category

    /** Use this category when recording audio. */
    @available(iOS 3.0, *)
    public static let record: AVAudioSession.Category

    /** Use this category when recording and playing back audio. */
    @available(iOS 3.0, *)
    public static let playAndRecord: AVAudioSession.Category

    /** Use this category to customize the usage of available audio accessories and built-in audio hardware.
     For example, this category provides an application with the ability to use an available USB output
     and headphone output simultaneously for separate, distinct streams of audio data. Use of
     this category by an application requires a more detailed knowledge of, and interaction with,
     the capabilities of the available audio routes.  May be used for input, output, or both.
     Note that not all output types and output combinations are eligible for multi-route.  Input is limited
     to the last-in input port. Eligible inputs consist of the following:
     AVAudioSessionPortUSBAudio, AVAudioSessionPortHeadsetMic, and AVAudioSessionPortBuiltInMic.
     Eligible outputs consist of the following:
     AVAudioSessionPortUSBAudio, AVAudioSessionPortLineOut, AVAudioSessionPortHeadphones, AVAudioSessionPortHDMI,
     and AVAudioSessionPortBuiltInSpeaker.
     Note that AVAudioSessionPortBuiltInSpeaker is only allowed to be used when there are no other eligible
     outputs connected.  */
    @available(iOS 6.0, *)
    public static let multiRoute: AVAudioSession.Category
  */

  // Call this right after setSessionActive, example: "soloAmbient"
  static Future<Map<Object?, Object?>> setSessionCategory(String category) async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('setSessionCategory', {'category': category});
    return result;
  }

  // Example: "soloAmbient"
  static Future<String?> get getCurrentSessionCategoryName async {
    final String? categoryName =
        await _channel.invokeMethod('getCurrentSessionCategoryName');
    return categoryName;
  }




  // ---------------------------- Port Names -----------------------------------

  /*
    // Line level input on a dock connector
    @available(iOS 6.0, *)
    public static let lineIn: AVAudioSession.Port

    /// Built-in microphone on an iOS device
    @available(iOS 6.0, *)
    public static let builtInMic: AVAudioSession.Port

    /// Microphone on a wired headset.  Headset refers to an accessory that has headphone outputs paired with a
    /// microphone.
    @available(iOS 6.0, *)
    public static let headsetMic: AVAudioSession.Port

    /// Line level output on a dock connector
    @available(iOS 6.0, *)
    public static let lineOut: AVAudioSession.Port

    /// Headphone or headset output
    @available(iOS 6.0, *)
    public static let headphones: AVAudioSession.Port

    /// Output on a Bluetooth A2DP device
    @available(iOS 6.0, *)
    public static let bluetoothA2DP: AVAudioSession.Port

    /// The speaker you hold to your ear when on a phone call
    @available(iOS 6.0, *)
    public static let builtInReceiver: AVAudioSession.Port

    /// Built-in speaker on an iOS device
    @available(iOS 6.0, *)
    public static let builtInSpeaker: AVAudioSession.Port

    /// Output via High-Definition Multimedia Interface
    @available(iOS 6.0, *)
    public static let HDMI: AVAudioSession.Port

    /// Output on a remote Air Play device
    @available(iOS 6.0, *)
    public static let airPlay: AVAudioSession.Port

    /// Output on a Bluetooth Low Energy device
    @available(iOS 7.0, *)
    public static let bluetoothLE: AVAudioSession.Port

    /// Input or output on a Bluetooth Hands-Free Profile device
    @available(iOS 6.0, *)
    public static let bluetoothHFP: AVAudioSession.Port

    /// Input or output on a Universal Serial Bus device
    @available(iOS 6.0, *)
    public static let usbAudio: AVAudioSession.Port

    /// Input or output via Car Audio
    @available(iOS 7.0, *)
    public static let carAudio: AVAudioSession.Port

    /// Input or output that does not correspond to real audio hardware
    @available(iOS 14.0, *)
    public static let virtual: AVAudioSession.Port

    /// Input or output connected via the PCI (Peripheral Component Interconnect) bus
    @available(iOS 14.0, *)
    public static let PCI: AVAudioSession.Port

    /// Input or output connected via FireWire
    @available(iOS 14.0, *)
    public static let fireWire: AVAudioSession.Port

    /// Input or output connected via DisplayPort
    @available(iOS 14.0, *)
    public static let displayPort: AVAudioSession.Port

    /// Input or output connected via AVB (Audio Video Bridging)
    @available(iOS 14.0, *)
    public static let AVB: AVAudioSession.Port

    /// Input or output connected via Thunderbolt
    @available(iOS 14.0, *)
    public static let thunderbolt: AVAudioSession.Port
*/

  static Future<String?> get getCurrentInputPortName async {
    final String? portName =
        await _channel.invokeMethod('getCurrentInputPortName');
    return portName;
  }

  static Future<String?> get getCurrentOutputPortName async {
    final String? portName =
        await _channel.invokeMethod('getCurrentOutputPortName');
    return portName;
  }




  //   --------------------------- Port Types ---------------------------------

  /*
    /* input port types */
    /// Line level input on a dock connector
    
    /// Built-in microphone on an iOS device
    
    /// Microphone on a wired headset.  Headset refers to an accessory that has headphone outputs paired with a
    /// microphone.
    
    /* output port types */
    
    /// Line level output on a dock connector
    
    /// Headphone or headset output
    
    /// Output on a Bluetooth A2DP device
    
    /// The speaker you hold to your ear when on a phone call
    
    /// Built-in speaker on an iOS device
    
    /// Output via High-Definition Multimedia Interface
    
    /// Output on a remote Air Play device
    
    /// Output on a Bluetooth Low Energy device
    
    /* port types that refer to either input or output */
    
    /// Input or output on a Bluetooth Hands-Free Profile device
    
    /// Input or output on a Universal Serial Bus device
    
    /// Input or output via Car Audio
    
    /// Input or output that does not correspond to real audio hardware
    
    /// Input or output connected via the PCI (Peripheral Component Interconnect) bus
    
    /// Input or output connected via FireWire
    
    /// Input or output connected via DisplayPort
    
    /// Input or output connected via AVB (Audio Video Bridging)
    
    /// Input or output connected via Thunderbolt
  */

  static Future<String?> get getCurrentInputPortType async {
    final String? portType =
        await _channel.invokeMethod('getCurrentInputPortName');
    return portType;
  }
  
  static Future<String?> get getCurrentOutputPortType async {
    final String? portType =
        await _channel.invokeMethod('getCurrentOutputPortType');
    return portType;
  }




  // --------------------------- Audio Player ----------------------------------

  static Future<double?> get getPlayerCurrentTimeInSeconds async {
    final double? seconds =
        await _channel.invokeMethod('getPlayerCurrentTimeInSeconds');
    return seconds;
  }

  static Future<bool?> get getPlayerIsPlaying async {
    final bool? isPlaying =
        await _channel.invokeMethod('getPlayerIsPlaying');
    return isPlaying;
  }

  static Future<Map<Object?, Object?>> setPlayerPlaybackSpeed(double playbackSpeed) async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('setPlayerPlaybackSpeed', {'playbackSpeed': playbackSpeed});
    return result;
  }

  static Future<Map<Object?, Object?>> get pausePlayer async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('pausePlayer');
    return result;
  }

  static Future<Map<Object?, Object?>> get resumePlayer async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('resumePlayer');
    return result;
  }

  static Future<Map<Object?, Object?>> seekPlayer(double percentage) async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('seekPlayer', {'percentage': percentage});
    return result;
  }

  static Future<Map<Object?, Object?>> rewindPlayer(double seconds) async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('rewindPlayer', {'seconds': seconds});
    return result;
  }

  static Future<Map<Object?, Object?>> playPlayer(String url, double rate, double position) async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('playPlayer', {'url': url, 'rate': rate, 'position': position});
    return result;
  }

  // -------------------------- Audio Recorder ---------------------------------

  // Call this before calling any recording methods
  static Future<Map<Object?, Object?>> get requestRecordPermission async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('requestRecordPermission');
    return result;
  }

  // Returns undetermined, denied or granted, currently crashing (?)
  static Future<String?> get getRecordPermissionState async {
    final String? recordPermissionState =
        await _channel.invokeMethod('getRecordPermissionState');
    return recordPermissionState;
  }

  static Future<bool?> get getRecorderIsRecording async {
    final bool? isRecording =
        await _channel.invokeMethod('getRecorderIsRecording');
    return isRecording;
  }

  static Future<bool?> get getRecorderIsSessionActive async {
    final bool? isSessionActive =
        await _channel.invokeMethod('getRecorderIsSessionActive');
    return isSessionActive;
  }

  static Future<Map<Object?, Object?>> get startRecordingSession async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('startRecordingSession');
    return result;
  }

  static Future<Map<Object?, Object?>> get pauseRecording async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('pauseRecording');
    return result;
  }

  static Future<Map<Object?, Object?>> get resumeRecording async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('resumeRecording');
    return result;
  }

  static Future<Map<Object?, Object?>> get deleteRecordingSession async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('deleteRecordingSession');
    return result;
  }

  /*
  ["success": ["url": audioRecordingResult.url.absoluteURL,
               "transcription": transcription,
               "recordedTimeInMilliseconds": audioRecordingResult.recordedTimeInMilliseconds]

               or

  ["error": "Failed to end recording session"]
  */
  static Future<Map<Object?, Object?>> get endRecordingSession async {
    final Map<Object?, Object?> result =
        await _channel.invokeMethod('endRecordingSession');
    return result;
  }




  // -------------------------- Event Listeners --------------------------------

  /*
  Missing listeners for:

  ["routeDidChange": ["inputPortName": inputPortName,
                                       "inputPortType": inputPortType,
                                       "outputPortName": outputPortName,
                                       "outputPortType": outputPortType]]

  "interruptionStarted"           

  "interruptionEnded"

  ["timelineDidChange": ["timePlayed": timePlayed,
                         "timeRemaining": timeRemaining,
                         "percentage": percentage]]

  ["millisecondsHeardDidChange": ["milliseconds": milliseconds,
                                  "percentage": percentage]]

  "playerDidFinishPlaying"

  ["recordedTimeDidChange": ["secondsRecorded": secondsRecorded]]
  */
}
