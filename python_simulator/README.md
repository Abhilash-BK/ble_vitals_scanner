# Python BLE Vitals Simulator

This is a separate testing tool for the assignment. It is not used inside the
Flutter Android app. The Flutter app still implements BLE functionality only
with `flutter_reactive_ble`.

The simulator advertises standard vitals services:

- Heart Rate Service: `0000180d-0000-1000-8000-00805f9b34fb`
- Heart Rate Measurement: `00002a37-0000-1000-8000-00805f9b34fb`
- Health Thermometer Service: `00001809-0000-1000-8000-00805f9b34fb`
- Temperature Measurement: `00002a1c-0000-1000-8000-00805f9b34fb`

## Run

```bash
pip install bless
python python_simulator/ble_vitals_simulator.py
```

Then open the Android app, scan, connect to `BLE Vitals Simulator`, and open the
device details screen. The app auto-reads and auto-subscribes to the standard
vitals characteristics when they are discovered.

BLE peripheral advertising support depends on your host OS, Bluetooth adapter,
and permissions. If Windows does not advertise reliably, use Linux or a
Raspberry Pi for the simulator.
