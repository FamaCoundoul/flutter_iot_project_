/// Domain entity representing a threshold configuration for a given sensor type.
///
/// Example sensorType values used by ESP32 API:
/// - "temperature"
/// - "light"
class Threshold {
  final String sensorType;
  final double threshold;
  final bool enabled;

  const Threshold({
    required this.sensorType,
    required this.threshold,
    required this.enabled,
  });

  Threshold copyWith({String? sensorType, double? threshold, bool? enabled}) {
    return Threshold(
      sensorType: sensorType ?? this.sensorType,
      threshold: threshold ?? this.threshold,
      enabled: enabled ?? this.enabled,
    );
  }
}
