import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ble_device_model.dart';
import '../providers/ble_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/permission_handler.dart';
import '../widgets/connection_status.dart';
import '../widgets/device_tile.dart';
import 'device_detail_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({
    this.autoStartScan = true,
    super.key,
  });

  final bool autoStartScan;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.autoStartScan) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _requestAndScan());
    }
  }

  Future<void> _requestAndScan() async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<BleProvider>();
    final granted = await BlePermissionHandler.requestBlePermissions();

    if (!mounted) {
      return;
    }

    if (granted) {
      await provider.startScan();
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Bluetooth and location permissions are required.'),
        ),
      );
    }
  }

  Future<void> _openDevice(BleDeviceModel device) async {
    final provider = context.read<BleProvider>();
    await provider.connectToDevice(device);

    if (!mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const DeviceDetailScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Vitals Scanner'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            onPressed: themeProvider.toggleTheme,
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ConnectionStatus(provider: provider),
          if (provider.errorMessage != null)
            MaterialBanner(
              content: Text(provider.errorMessage!),
              leading: const Icon(Icons.error_outline),
              actions: [
                TextButton(
                  onPressed: provider.clearError,
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _requestAndScan,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (provider.recentDevices.isNotEmpty) ...[
                    Text(
                      'Recently connected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    for (final device in provider.recentDevices)
                      DeviceTile(
                        device: device,
                        onTap: () => _openDevice(device),
                      ),
                    const SizedBox(height: 20),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Discovered devices',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: provider.isScanning
                            ? provider.stopScan
                            : _requestAndScan,
                        icon: Icon(
                          provider.isScanning ? Icons.stop : Icons.search,
                        ),
                        label: Text(provider.isScanning ? 'Stop' : 'Scan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (provider.isScanning)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(),
                    ),
                  if (provider.discoveredDevices.isEmpty)
                    const _EmptyScanState()
                  else
                    for (final device in provider.discoveredDevices)
                      DeviceTile(
                        device: device,
                        onTap: () => _openDevice(device),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyScanState extends StatelessWidget {
  const _EmptyScanState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(
            Icons.bluetooth_searching,
            size: 56,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No BLE devices found yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep the device nearby and pull down to scan again.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
