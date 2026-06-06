import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../providers/ble_provider.dart';

class ConnectionStatus extends StatelessWidget {
  const ConnectionStatus({required this.provider, super.key});

  final BleProvider provider;

  @override
  Widget build(BuildContext context) {
    final connectionState = provider.connectionState;
    final connected = connectionState == DeviceConnectionState.connected;
    final color = connected
        ? Colors.green
        : connectionState == DeviceConnectionState.connecting
            ? Colors.orange
            : Colors.red;

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _connectionLabel(connectionState),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text('Adapter: ${provider.bleStatus.name}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _connectionLabel(DeviceConnectionState state) {
    return switch (state) {
      DeviceConnectionState.connected => 'Connected',
      DeviceConnectionState.connecting => 'Connecting',
      DeviceConnectionState.disconnecting => 'Disconnecting',
      DeviceConnectionState.disconnected => 'Disconnected',
    };
  }
}
