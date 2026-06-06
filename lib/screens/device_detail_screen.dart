import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart'
    hide ConnectionStatus;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/ble_provider.dart';
import '../utils/ble_utils.dart';
import '../widgets/characteristic_tile.dart';
import '../widgets/connection_status.dart';

class DeviceDetailScreen extends StatelessWidget {
  const DeviceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BleProvider>();
    final device = provider.selectedDevice;
    final latestVital = provider.latestVital;

    return Scaffold(
      appBar: AppBar(
        title: Text(device?.name ?? 'Device details'),
        actions: [
          IconButton(
            tooltip: 'Refresh services',
            onPressed: provider.isConnected ? provider.discoverServices : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: device == null
          ? const Center(child: Text('No device selected.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ConnectionStatus(provider: provider),
                const SizedBox(height: 12),
                _DeviceSummary(deviceId: device.id),
                const SizedBox(height: 16),
                if (latestVital != null) _VitalsCard(provider: provider),
                if (latestVital != null) const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Services and characteristics',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (provider.isDiscoveringServices)
                      const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (provider.services.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No services discovered yet.'),
                    ),
                  )
                else
                  for (final service in provider.services)
                    _ServiceCard(service: service),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () async {
                    await context.read<BleProvider>().disconnect();
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.bluetooth_disabled),
                  label: const Text('Disconnect'),
                ),
              ],
            ),
    );
  }
}

class _DeviceSummary extends StatelessWidget {
  const _DeviceSummary({required this.deviceId});

  final String deviceId;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device ID', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            SelectableText(deviceId),
          ],
        ),
      ),
    );
  }
}

class _VitalsCard extends StatelessWidget {
  const _VitalsCard({required this.provider});

  final BleProvider provider;

  @override
  Widget build(BuildContext context) {
    final latest = provider.latestVital;
    if (latest == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Latest vitals', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _MetricChip(
                  label: 'Heart rate',
                  value: latest.heartRate == null
                      ? '--'
                      : '${latest.heartRate} bpm',
                  icon: Icons.favorite,
                ),
                _MetricChip(
                  label: 'Temperature',
                  value: latest.temperature == null
                      ? '--'
                      : '${latest.temperature!.toStringAsFixed(1)} C',
                  icon: Icons.thermostat,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Updated ${DateFormat.Hms().format(latest.timestamp)} from '
              '${latest.sourceUuid == null ? 'unknown' : BleUtils.shortUuid(latest.sourceUuid!)}',
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final DiscoveredService service;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text('Service ${BleUtils.shortUuid(service.serviceId.toString())}'),
        subtitle: SelectableText(service.serviceId.toString()),
        children: [
          if (service.characteristics.isEmpty)
            const ListTile(title: Text('No characteristics'))
          else
            for (final characteristic in service.characteristics)
              CharacteristicTile(
                serviceId: service.serviceId,
                characteristic: characteristic,
              ),
        ],
      ),
    );
  }
}
