# Python BLE Simulator

This optional simulator advertises a BLE heart-rate service that the Flutter app
can scan, connect to, and subscribe to for changing vitals.

## Setup

```bash
pip install bless
python python_simulator/ble_simulator.py
```

BLE peripheral advertising support depends on the host OS, Bluetooth adapter,
and permissions. Use a real BLE peripheral for final Android-device validation.
