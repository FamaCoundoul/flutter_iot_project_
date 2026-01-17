import '../../domain/entities/threshold.dart';

/// Data model for ESP32 threshold payload.
///
/// API shapes:
/// - GET /api/thresholds -> { "thresholds": [ {sensorType, threshold, enabled}, ...], "timestamp": ... }
/// - POST /api/thresholds -> {sensorType, threshold, enabled, timestamp}
class ThresholdModel extends Threshold {
  final int? timestamp;

  const ThresholdModel({
    required super.sensorType,
    required super.threshold,
    required super.enabled,
    this.timestamp,
  });

  factory ThresholdModel.fromJson(Map<String, dynamic> json) {
    final th = json['threshold'];
    return ThresholdModel(
      sensorType: (json['sensorType'] ?? '').toString(),
      threshold: (th is num)
          ? th.toDouble()
          : double.tryParse(th?.toString() ?? '') ?? 0.0,
      enabled: (json['enabled'] is bool)
          ? json['enabled'] as bool
          : (json['enabled']?.toString() == 'true'),
      timestamp: (json['timestamp'] is num)
          ? (json['timestamp'] as num).toInt()
          : int.tryParse(json['timestamp']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'sensorType': sensorType,
    'threshold': threshold,
    'enabled': enabled,
    if (timestamp != null) 'timestamp': timestamp,
  };
}
