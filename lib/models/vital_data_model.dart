class VitalDataModel {
  const VitalDataModel({
    required this.timestamp,
    required this.rawBytes,
    this.heartRate,
    this.temperature,
    this.sourceUuid,
  });

  final DateTime timestamp;
  final int? heartRate;
  final double? temperature;
  final List<int> rawBytes;
  final String? sourceUuid;

  bool get hasParsedValue => heartRate != null || temperature != null;
}
