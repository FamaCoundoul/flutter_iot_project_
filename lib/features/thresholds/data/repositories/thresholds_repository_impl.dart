import '../../domain/entities/threshold.dart';
import '../../domain/repositories/thresholds_repository.dart';
import '../datasources/thresholds_remote_datasource.dart';
import '../datasources/thresholds_firestore_datasource.dart';

class ThresholdsRepositoryImpl implements ThresholdsRepository {
  final ThresholdsRemoteDataSource remote;
  final ThresholdsFirestoreDataSource firestore;

  ThresholdsRepositoryImpl(
      this.remote, {
        required this.firestore,
      });

  @override
  Future<List<Threshold>> getThresholds() async {
    // Pour l’instant: on récupère depuis l’API ESP32 (remote)
    // Tu peux ensuite ajouter un cache Firestore si tu veux.
    final models = await remote.getThresholds();
    return models;
  }

  @override
  Future<Threshold> updateThreshold({
    required String sensorType,
    double? threshold,
    bool? enabled,
  }) async {
    final model = await remote.updateThreshold(
      sensorType: sensorType,
      threshold: threshold,
      enabled: enabled,
    );
    return model;
  }
}
