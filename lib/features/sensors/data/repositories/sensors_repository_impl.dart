import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/sensors_firestore_datasource.dart';
import '../datasources/sensors_remote_datasource.dart';
import '../../domain/entities/sensor.dart';
import '../../domain/repositories/sensors_repository.dart';

class SensorsRepositoryImpl implements SensorsRepository {
  final SensorsRemoteDataSource remoteDataSource;
  final SensorsFirestoreDataSource? firestoreDataSource;

  SensorsRepositoryImpl(
      this.remoteDataSource, {
        this.firestoreDataSource,
      });

  @override
  Future<List<Sensor>> getSensors() async {
    try {
      final sensors = await remoteDataSource.getSensors();

      // Sauvegarder dans Firestore (async, ne pas attendre)
      if (firestoreDataSource != null) {
        firestoreDataSource!.saveSensorsData(sensors).catchError((e) {
          print('⚠️ Failed to save to Firestore: $e');
        });
      }

      return sensors;
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<Sensor> getSensorById(int id) async {
    try {
      return await remoteDataSource.getSensorById(id);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Stream<List<Sensor>> streamSensors() {
    // Polling toutes les 2 secondes
    return Stream.periodic(
      const Duration(seconds: 2),
          (_) async {
        try {
          return await getSensors();
        } catch (e) {
          print('Error in stream: $e');
          return <Sensor>[];
        }
      },
    ).asyncMap((future) => future);
  }
}