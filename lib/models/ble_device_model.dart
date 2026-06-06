import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleDeviceModel {
  const BleDeviceModel({
    required this.id,
    required this.name,
    required this.rssi,
    required this.serviceUuids,
    required this.lastSeen,
    this.isRecent = false,
  });

  factory BleDeviceModel.fromDiscoveredDevice(
    DiscoveredDevice device, {
    bool isRecent = false,
  }) {
    return BleDeviceModel(
      id: device.id,
      name: device.name.isEmpty ? 'Unknown Device' : device.name,
      rssi: device.rssi,
      serviceUuids: device.serviceUuids.map((uuid) => uuid.toString()).toList(),
      lastSeen: DateTime.now(),
      isRecent: isRecent,
    );
  }

  factory BleDeviceModel.fromJson(Map<String, dynamic> json) {
    return BleDeviceModel(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Unknown Device',
      rssi: json['rssi'] as int? ?? -127,
      serviceUuids: (json['serviceUuids'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      lastSeen: DateTime.tryParse(json['lastSeen'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isRecent: json['isRecent'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final int rssi;
  final List<String> serviceUuids;
  final DateTime lastSeen;
  final bool isRecent;

  BleDeviceModel copyWith({
    String? id,
    String? name,
    int? rssi,
    List<String>? serviceUuids,
    DateTime? lastSeen,
    bool? isRecent,
  }) {
    return BleDeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      rssi: rssi ?? this.rssi,
      serviceUuids: serviceUuids ?? this.serviceUuids,
      lastSeen: lastSeen ?? this.lastSeen,
      isRecent: isRecent ?? this.isRecent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rssi': rssi,
      'serviceUuids': serviceUuids,
      'lastSeen': lastSeen.toIso8601String(),
      'isRecent': isRecent,
    };
  }
}
