class AppConstants {
  static const appName = 'BLE Vitals Scanner';
  static const recentDevicesKey = 'recent_ble_devices';

  static const heartRateServiceUuid = '0000180d-0000-1000-8000-00805f9b34fb';
  static const heartRateMeasurementUuid =
      '00002a37-0000-1000-8000-00805f9b34fb';
  static const temperatureMeasurementUuid =
      '00002a1c-0000-1000-8000-00805f9b34fb';

  static const maxRecentDevices = 8;
  static const maxVitalSamples = 120;
}
