import '../entities/threshold.dart';

abstract class ThresholdsRepository {
  Future<List<Threshold>> getThresholds();

  Future<Threshold> updateThreshold({
    required String sensorType,
    double? threshold,
    bool? enabled,
  });
}
