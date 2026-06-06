import 'dart:convert';

import '../models/vital_data_model.dart';
import 'constants.dart';

class BleUtils {
  static String formatBytes(List<int> bytes) {
    if (bytes.isEmpty) {
      return 'No data';
    }

    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');
  }

  static String tryDecodeUtf8(List<int> bytes) {
    try {
      return utf8.decode(bytes, allowMalformed: false);
    } catch (_) {
      return '';
    }
  }

  static String shortUuid(String uuid) {
    final normalized = uuid.toLowerCase();
    if (normalized.startsWith('0000') &&
        normalized.endsWith('-0000-1000-8000-00805f9b34fb')) {
      return normalized.substring(4, 8).toUpperCase();
    }
    return uuid;
  }

  static VitalDataModel parseVitalData(String characteristicUuid, List<int> data) {
    final normalized = characteristicUuid.toLowerCase();
    int? heartRate;
    double? temperature;

    if (normalized == AppConstants.heartRateMeasurementUuid && data.length >= 2) {
      final isUint16 = (data.first & 0x01) == 0x01;
      heartRate = isUint16 && data.length >= 3
          ? data[1] | (data[2] << 8)
          : data[1];
    } else if (normalized == AppConstants.temperatureMeasurementUuid &&
        data.length >= 2) {
      temperature = (data[0] | (data[1] << 8)) / 10.0;
    } else if (data.isNotEmpty) {
      heartRate = data.first >= 30 && data.first <= 220 ? data.first : null;
      if (data.length >= 3 && data[1] >= 0) {
        final rawTemperature = data[1] | (data[2] << 8);
        final candidate = rawTemperature / 10.0;
        temperature = candidate >= 25 && candidate <= 45 ? candidate : null;
      }
    }

    return VitalDataModel(
      timestamp: DateTime.now(),
      sourceUuid: characteristicUuid,
      heartRate: heartRate,
      temperature: temperature,
      rawBytes: List<int>.unmodifiable(data),
    );
  }

  static String describeRssi(int rssi) {
    if (rssi >= -60) {
      return 'Strong';
    }
    if (rssi >= -75) {
      return 'Good';
    }
    if (rssi >= -90) {
      return 'Weak';
    }
    return 'Very weak';
  }
}
