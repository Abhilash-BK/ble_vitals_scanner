# BLE Vitals Scanner

BLE Vitals Scanner is an Android-focused Flutter application for discovering,
connecting to, and monitoring Bluetooth Low Energy devices in real time. It can
scan nearby BLE peripherals, connect to a selected device, discover GATT
services and characteristics, read characteristic values, subscribe to
notifications, and parse common heart-rate and temperature payloads into live
vitals.

The project also includes an optional Python BLE simulator for testing the app
without a dedicated vitals peripheral, subject to host Bluetooth support.

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
- Light/dark theme toggle
- Android runtime permission handling
- Optional Python BLE vitals simulator

## Tech Stack

- Flutter 3.44.1
- Dart 3.12.1
- Android SDK 36
- `flutter_reactive_ble`
- `provider`
- `permission_handler`
- `shared_preferences`
- Python simulator using `bless`

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
python_simulator/
  ble_simulator.py
  README.md
```

## Requirements

- Flutter SDK 3.19 or newer
- Android Studio with Android SDK installed
- Physical Android device with BLE support
- Android 10 or newer recommended
- Python 3.10 or newer for the optional simulator

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

## Python BLE Simulator

The simulator advertises a BLE heart-rate service and publishes changing heart
rate and temperature values.

```bash
pip install bless
python python_simulator/ble_simulator.py
```

Advertised UUIDs:

- Vitals service: `0000180d-0000-1000-8000-00805f9b34fb`
- Heart rate characteristic: `00002a37-0000-1000-8000-00805f9b34fb`
- Temperature characteristic: `00002a1c-0000-1000-8000-00805f9b34fb`

Simulator support depends on the host operating system, Bluetooth adapter, and
permission model. Use a real BLE device for final validation.

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
