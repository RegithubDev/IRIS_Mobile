import 'package:permission_handler/permission_handler.dart';

class PermissionRequest {
  void requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.storage,
    ].request();

    statuses.values.forEach((element) async {
      if (element.isDenied || element.isPermanentlyDenied) {
        await openAppSettings();
      }
    });
  }
}
