# BLE Vitals Scanner

BLE Vitals Scanner is an Android-focused Flutter application for discovering,
connecting to, and monitoring Bluetooth Low Energy devices in real time. It can
scan nearby BLE peripherals, connect to a selected device, discover GATT
services and characteristics, read characteristic values, subscribe to
notifications, and parse common heart-rate and temperature payloads into live
vitals.

All application logic is implemented in Flutter/Dart. BLE functionality is
implemented only with `flutter_reactive_ble`. No custom native Android or iOS
feature code is included; the Android directory is the standard Flutter build
scaffold with the required Android permissions.

## Features

- BLE device scanning and discovery
- RSSI display and signal-quality labels
- Device connection and disconnection flow
- GATT service and characteristic discovery
- Characteristic read support
- Notify/indicate subscription support
- Live parsed vitals for heart rate and temperature
- Raw byte and UTF-8 characteristic display
- Recent device persistence with `shared_preferences`
- Dark theme by default with a light/dark toggle
- Scan starts on launch and stops automatically after 10 seconds
- Android runtime permission handling

## Constraints Compliance

- BLE functionality uses only `flutter_reactive_ble`.
- App feature logic is Flutter/Dart only.
- No custom native Android/iOS code is used for app features or BLE behavior.
- Android support is included and mandatory.
- iOS support is not included in this MVP.

## Tech Stack

- Flutter 3.44.1
- Dart 3.12.1
- Android SDK 36
- `flutter_reactive_ble`
- `provider`
- `permission_handler`
- `shared_preferences`
- `intl`

## Project Structure

```text
lib/
  main.dart
  models/
    ble_device_model.dart
    vital_data_model.dart
  providers/
    ble_provider.dart
    theme_provider.dart
  screens/
    scan_screen.dart
    device_detail_screen.dart
  utils/
    ble_utils.dart
    constants.dart
    permission_handler.dart
  widgets/
    characteristic_tile.dart
    connection_status.dart
    device_tile.dart
android/
  Standard Flutter Android scaffold and permission configuration
test/
  widget_test.dart
```

## Requirements

- Flutter SDK 3.19 or newer
- Android Studio with Android SDK installed
- Physical Android device with BLE support
- Android 10 or newer recommended

BLE scanning and connection testing should be done on a physical Android device.
Most emulators do not expose real BLE hardware.

## Setup

```bash
flutter pub get
```

## Run on Android

```bash
flutter run
```

Grant Bluetooth and location permissions when prompted. On Android 12 and newer,
the app requests `BLUETOOTH_SCAN` and `BLUETOOTH_CONNECT`. On older Android
versions, location permission is still needed for BLE scanning.

## Build APK

```bash
flutter build apk --debug
```

The debug APK is generated at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Testing

Use a real BLE device with readable or notifiable GATT characteristics, such as a
BLE heart-rate monitor or a microcontroller configured as a BLE peripheral.

Recommended checks:

1. Grant Android Bluetooth/location permissions.
2. Watch the real-time scan list populate for 10 seconds.
3. Connect to a selected device.
4. Verify services and characteristics appear.
5. Read readable characteristics.
6. Subscribe to notify/indicate characteristics.
7. Confirm parsed vitals or raw characteristic bytes update in the UI.

## Validation

The project has been checked with:

```bash
flutter analyze
flutter test
flutter build apk --debug
```

The Android build currently emits a warning from `reactive_ble_mobile` about the
plugin applying the Kotlin Gradle Plugin. The app builds successfully, but the
plugin may need an upstream update for future Flutter versions.

## Notes

- The first version is a Core BLE MVP.
- Charts, data export, background scanning, multiple simultaneous device
  connections, and cloud sync are intentionally deferred.
- The original detailed assignment brief is preserved in the `README` file.
