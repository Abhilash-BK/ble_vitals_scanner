import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class BlePermissionHandler {
  static Future<bool> requestBlePermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final hasAndroid12BlePermissions =
        statuses[Permission.bluetoothScan]?.isGranted == true &&
            statuses[Permission.bluetoothConnect]?.isGranted == true;
    final hasLegacyLocationPermission =
        statuses[Permission.locationWhenInUse]?.isGranted == true;

    return hasAndroid12BlePermissions || hasLegacyLocationPermission;
  }

  static Future<bool> hasBlePermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    final scan = await Permission.bluetoothScan.status;
    final connect = await Permission.bluetoothConnect.status;
    final location = await Permission.locationWhenInUse.status;

    return (scan.isGranted && connect.isGranted) || location.isGranted;
  }
}
