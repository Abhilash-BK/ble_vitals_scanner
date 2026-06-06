import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import '../providers/ble_provider.dart';
import '../utils/ble_utils.dart';

class CharacteristicTile extends StatelessWidget {
  const CharacteristicTile({
    required this.serviceId,
    required this.characteristic,
    super.key,
  });

  final Uuid serviceId;
  final DiscoveredCharacteristic characteristic;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BleProvider>();
    final selectedDevice = provider.selectedDevice;
    if (selectedDevice == null) {
      return const SizedBox.shrink();
    }

    final qualifiedCharacteristic = QualifiedCharacteristic(
      serviceId: serviceId,
      characteristicId: characteristic.characteristicId,
      deviceId: selectedDevice.id,
    );
    final value =
        provider.characteristicValues[characteristic.characteristicId.toString()];
    final isSubscribed = provider.isSubscribed(qualifiedCharacteristic);

    return ListTile(
      title: Text(
        'Characteristic '
        '${BleUtils.shortUuid(characteristic.characteristicId.toString())}',
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(characteristic.characteristicId.toString()),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (characteristic.isReadable) const _PropertyChip(label: 'Read'),
              if (characteristic.isWritableWithResponse)
                const _PropertyChip(label: 'Write'),
              if (characteristic.isWritableWithoutResponse)
                const _PropertyChip(label: 'Write no response'),
              if (characteristic.isNotifiable)
                const _PropertyChip(label: 'Notify'),
              if (characteristic.isIndicatable)
                const _PropertyChip(label: 'Indicate'),
            ],
          ),
          if (value != null) ...[
            const SizedBox(height: 8),
            Text('Raw: ${BleUtils.formatBytes(value)}'),
            if (BleUtils.tryDecodeUtf8(value).isNotEmpty)
              Text('Text: ${BleUtils.tryDecodeUtf8(value)}'),
          ],
        ],
      ),
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            tooltip: 'Read',
            onPressed: characteristic.isReadable
                ? () => context
                    .read<BleProvider>()
                    .readCharacteristic(qualifiedCharacteristic)
                : null,
            icon: const Icon(Icons.download),
          ),
          IconButton(
            tooltip: isSubscribed ? 'Stop notifications' : 'Subscribe',
            onPressed: characteristic.isNotifiable || characteristic.isIndicatable
                ? () => context
                    .read<BleProvider>()
                    .subscribeToCharacteristic(qualifiedCharacteristic)
                : null,
            icon: Icon(isSubscribed ? Icons.notifications_active : Icons.sensors),
          ),
        ],
      ),
    );
  }
}

class _PropertyChip extends StatelessWidget {
  const _PropertyChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}
