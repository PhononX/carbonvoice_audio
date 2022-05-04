import 'package:permission_handler/permission_handler.dart';

class PermissionState {
  PermissionStatus permissionStatus;
  Permission permission;
  PermissionState({required this.permissionStatus, required this.permission});

  Future<PermissionState> request() async {
    permissionStatus = await permission.request();
    return this;
  }

  Future<PermissionState> checkAndRequest() async {
    if (!await permission.isGranted) {
      permissionStatus = await permission.request();
    }
    return this;
  }

  bool get isAllowed => permissionStatus == PermissionStatus.granted;
}
