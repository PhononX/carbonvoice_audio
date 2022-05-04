import 'package:permission_handler/permission_handler.dart';

import 'cv_audio_permissions_state.dart' if (dart.library.html) 'cv_audio_permissions_state_web.dart';

class CarbonVoiceAudioPermissions {
  PermissionState microphone;

  CarbonVoiceAudioPermissions({required this.microphone});

  static Future<CarbonVoiceAudioPermissions> check() async {
    return CarbonVoiceAudioPermissions(microphone: await _Permissions.microphone.check());
  }
}

class _Permissions {
  static final microphone = PermissionState(
    permission: Permission.microphone,
    permissionStatus: PermissionStatus.denied,
  );
}
