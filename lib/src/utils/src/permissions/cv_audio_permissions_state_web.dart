import 'dart:html' as html;
import 'package:permission_handler/permission_handler.dart';

class PermissionState {
  PermissionStatus permissionStatus;
  Permission permission;
  PermissionState({required this.permissionStatus, required this.permission});

  Future<PermissionState> request() async {
    permissionStatus = await Permissions.checkPermissions() ? PermissionStatus.granted : PermissionStatus.denied;
    return this;
  }

  Future<PermissionState> check() async {
    permissionStatus = await Permissions.checkPermissions() ? PermissionStatus.granted : PermissionStatus.denied;

    return this;
  }

  Future<PermissionState> checkAndRequest() async {
    permissionStatus = await Permissions.checkPermissions() ? PermissionStatus.granted : PermissionStatus.denied;
    return this;
  }

  bool get isAllowed => permissionStatus == PermissionStatus.granted;
}

class Permissions {
  static html.MediaStream? stream;

  static Future<bool> checkPermissions() async {
    var permissionGranted = false;
    try {
      var constraints = {'audio': true, 'video': false};
      var stream = await html.window.navigator.mediaDevices!.getUserMedia(constraints);
      permissionGranted = stream.active == true ? true : false;
      return permissionGranted;
    } catch (e) {
      permissionGranted = false;
    } finally {
      return permissionGranted;
    }
  }

  // static Future<bool> checkSpeechPermissions(
  //     Instrumentation instrumentation) async {
  //   var permissionGranted = false;
  //   try {
  //     var constraints = {'audio': true, 'video': false};
  //     var stream =
  //         await html.window.navigator.mediaDevices!.getUserMedia(constraints);
  //     permissionGranted = stream.active == true ? true : false;
  //     if (permissionGranted == false) {
  //       instrumentation.noMicrophonePermissions();
  //     } else {
  //       instrumentation.microphonePermissionsAllowed();
  //     }
  //   } catch (e) {
  //     permissionGranted = false;
  //     instrumentation.noMicrophonePermissions();
  //   } finally {
  //     return permissionGranted;
  //   }
  // }

}
