import '../entities/threshold.dart';
import '../repositories/thresholds_repository.dart';

class UpdateThreshold {
  final ThresholdsRepository repository;

  UpdateThreshold(this.repository);

  Future<Threshold> call({
    required String sensorType,
    double? threshold,
    bool? enabled,
  }) {
    return repository.updateThreshold(
      sensorType: sensorType,
      threshold: threshold,
      enabled: enabled,
    );
  }
}
