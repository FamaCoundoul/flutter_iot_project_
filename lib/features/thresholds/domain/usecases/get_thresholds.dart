import '../entities/threshold.dart';
import '../repositories/thresholds_repository.dart';

class GetThresholds {
  final ThresholdsRepository repository;

  GetThresholds(this.repository);

  Future<List<Threshold>> call() => repository.getThresholds();
}
