import 'package:flutter/material.dart';

import '../models/ble_device_model.dart';
import '../utils/ble_utils.dart';

class DeviceTile extends StatelessWidget {
  const DeviceTile({
    required this.device,
    required this.onTap,
    super.key,
  });

  final BleDeviceModel device;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(device.isRecent ? Icons.history : Icons.bluetooth),
        ),
        title: Text(device.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(device.id),
            Text('${BleUtils.describeRssi(device.rssi)} signal (${device.rssi} dBm)'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
