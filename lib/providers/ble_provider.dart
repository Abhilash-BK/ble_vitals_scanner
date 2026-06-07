import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ble_device_model.dart';
import '../models/vital_data_model.dart';
import '../utils/ble_utils.dart';
import '../utils/constants.dart';

class BleProvider extends ChangeNotifier {
  BleProvider({bool enableBleClient = true})
      : _ble = enableBleClient ? FlutterReactiveBle() : null;

  final FlutterReactiveBle? _ble;

  StreamSubscription<BleStatus>? _statusSubscription;
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  Timer? _scanTimeoutTimer;
  final Map<String, StreamSubscription<List<int>>> _notifySubscriptions = {};

  final Map<String, BleDeviceModel> _discoveredDevices = {};
  List<BleDeviceModel> _recentDevices = [];
  List<DiscoveredService> _services = [];
  final Map<String, List<int>> _characteristicValues = {};
  final List<VitalDataModel> _vitalData = [];

  BleStatus _bleStatus = BleStatus.unknown;
  DeviceConnectionState _connectionState = DeviceConnectionState.disconnected;
  BleDeviceModel? _selectedDevice;
  bool _isScanning = false;
  bool _isDiscoveringServices = false;
  String? _errorMessage;

  BleStatus get bleStatus => _bleStatus;
  DeviceConnectionState get connectionState => _connectionState;
  BleDeviceModel? get selectedDevice => _selectedDevice;
  bool get isScanning => _isScanning;
  bool get isDiscoveringServices => _isDiscoveringServices;
  String? get errorMessage => _errorMessage;
  List<DiscoveredService> get services => List.unmodifiable(_services);
  Map<String, List<int>> get characteristicValues =>
      Map.unmodifiable(_characteristicValues);
  List<VitalDataModel> get vitalData => List.unmodifiable(_vitalData);
  VitalDataModel? get latestVital =>
      _vitalData.isEmpty ? null : _vitalData.last;
  bool get isConnected =>
      _connectionState == DeviceConnectionState.connected &&
      _selectedDevice != null;

  List<BleDeviceModel> get discoveredDevices {
    final devices = _discoveredDevices.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));
    return List.unmodifiable(devices);
  }

  List<BleDeviceModel> get recentDevices => List.unmodifiable(_recentDevices);

  Future<void> initialize() async {
    await _loadRecentDevices();
    final ble = _ble;
    if (ble == null) {
      return;
    }

    _statusSubscription = ble.statusStream.listen((status) {
      _bleStatus = status;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> startScan() async {
    await stopScan();
    _errorMessage = null;
    _discoveredDevices.clear();
    _isScanning = true;
    notifyListeners();

    final ble = _ble;
    if (ble == null) {
      _errorMessage = 'BLE client is not available in this environment.';
      _isScanning = false;
      notifyListeners();
      return;
    }

    _scanSubscription = ble
        .scanForDevices(
          withServices: const [],
          scanMode: ScanMode.lowLatency,
        )
        .listen(
      (device) {
        final isRecent =
            _recentDevices.any((recentDevice) => recentDevice.id == device.id);
        _discoveredDevices[device.id] = BleDeviceModel.fromDiscoveredDevice(
          device,
          isRecent: isRecent,
        );
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = 'Scan failed: $error';
        _isScanning = false;
        notifyListeners();
      },
    );

    _scanTimeoutTimer = Timer(const Duration(seconds: 10), () {
      stopScan();
    });
  }

  Future<void> stopScan() async {
    _scanTimeoutTimer?.cancel();
    _scanTimeoutTimer = null;
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    if (_isScanning) {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> connectToDevice(BleDeviceModel device) async {
    await stopScan();
    await disconnect(clearSelection: false);

    _selectedDevice = device;
    _connectionState = DeviceConnectionState.connecting;
    _services = [];
    _characteristicValues.clear();
    _vitalData.clear();
    _errorMessage = null;
    notifyListeners();

    final ble = _ble;
    if (ble == null) {
      _errorMessage = 'BLE client is not available in this environment.';
      _connectionState = DeviceConnectionState.disconnected;
      notifyListeners();
      return;
    }

    _connectionSubscription = ble
        .connectToDevice(
          id: device.id,
          connectionTimeout: const Duration(seconds: 30),
        )
        .listen(
      (update) async {
        _connectionState = update.connectionState;
        notifyListeners();

        if (update.connectionState == DeviceConnectionState.connected) {
          await _saveRecentDevice(device);
          await discoverServices();
        }
      },
      onError: (Object error) {
        _errorMessage = 'Connection failed: $error';
        _connectionState = DeviceConnectionState.disconnected;
        notifyListeners();
      },
    );
  }

  Future<void> disconnect({bool clearSelection = true}) async {
    for (final subscription in _notifySubscriptions.values) {
      await subscription.cancel();
    }
    _notifySubscriptions.clear();

    await _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _connectionState = DeviceConnectionState.disconnected;
    _services = [];
    _characteristicValues.clear();

    if (clearSelection) {
      _selectedDevice = null;
    }
    notifyListeners();
  }

  Future<void> discoverServices() async {
    final device = _selectedDevice;
    if (device == null) {
      return;
    }

    _isDiscoveringServices = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ble = _ble;
      if (ble == null) {
        _errorMessage = 'BLE client is not available in this environment.';
        return;
      }

      // The deprecated API returns DiscoveredService, which pairs directly with
      // QualifiedCharacteristic for the current MVP read/subscribe workflow.
      // ignore: deprecated_member_use
      _services = await ble.discoverServices(device.id);
    } catch (error) {
      _errorMessage = 'Service discovery failed: $error';
    } finally {
      _isDiscoveringServices = false;
      notifyListeners();
    }
  }

  Future<void> readCharacteristic(QualifiedCharacteristic characteristic) async {
    try {
      final ble = _ble;
      if (ble == null) {
        _errorMessage = 'BLE client is not available in this environment.';
        notifyListeners();
        return;
      }

      final data = await ble.readCharacteristic(characteristic);
      _storeCharacteristicData(characteristic.characteristicId.toString(), data);
    } catch (error) {
      _errorMessage = 'Read failed: $error';
      notifyListeners();
    }
  }

  Future<void> subscribeToCharacteristic(
    QualifiedCharacteristic characteristic,
  ) async {
    final key = _characteristicKey(characteristic);
    if (_notifySubscriptions.containsKey(key)) {
      await _notifySubscriptions.remove(key)?.cancel();
      notifyListeners();
      return;
    }

    final ble = _ble;
    if (ble == null) {
      _errorMessage = 'BLE client is not available in this environment.';
      notifyListeners();
      return;
    }

    _notifySubscriptions[key] = ble.subscribeToCharacteristic(characteristic).listen(
      (data) {
        _storeCharacteristicData(characteristic.characteristicId.toString(), data);
      },
      onError: (Object error) {
        _errorMessage = 'Subscription failed: $error';
        notifyListeners();
      },
    );
    notifyListeners();
  }

  bool isSubscribed(QualifiedCharacteristic characteristic) {
    return _notifySubscriptions.containsKey(_characteristicKey(characteristic));
  }

  void _storeCharacteristicData(String characteristicUuid, List<int> data) {
    _characteristicValues[characteristicUuid] = List<int>.unmodifiable(data);

    final vitalData = BleUtils.parseVitalData(characteristicUuid, data);
    if (vitalData.hasParsedValue) {
      _vitalData.add(vitalData);
      if (_vitalData.length > AppConstants.maxVitalSamples) {
        _vitalData.removeRange(
          0,
          _vitalData.length - AppConstants.maxVitalSamples,
        );
      }
    }
    notifyListeners();
  }

  String _characteristicKey(QualifiedCharacteristic characteristic) {
    return '${characteristic.deviceId}|${characteristic.serviceId}|'
        '${characteristic.characteristicId}';
  }

  Future<void> _loadRecentDevices() async {
    final preferences = await SharedPreferences.getInstance();
    final encodedDevices =
        preferences.getStringList(AppConstants.recentDevicesKey) ?? const [];

    _recentDevices = encodedDevices
        .map((encodedDevice) {
          try {
            return BleDeviceModel.fromJson(
              jsonDecode(encodedDevice) as Map<String, dynamic>,
            ).copyWith(isRecent: true);
          } catch (_) {
            return null;
          }
        })
        .whereType<BleDeviceModel>()
        .toList();
  }

  Future<void> _saveRecentDevice(BleDeviceModel device) async {
    final updatedDevice = device.copyWith(isRecent: true, lastSeen: DateTime.now());
    _recentDevices = [
      updatedDevice,
      ..._recentDevices.where((recentDevice) => recentDevice.id != device.id),
    ].take(AppConstants.maxRecentDevices).toList();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      AppConstants.recentDevicesKey,
      _recentDevices
          .map((recentDevice) => jsonEncode(recentDevice.toJson()))
          .toList(),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _scanTimeoutTimer?.cancel();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    for (final subscription in _notifySubscriptions.values) {
      subscription.cancel();
    }
    super.dispose();
  }
}
