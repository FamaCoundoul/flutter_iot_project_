import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/device_firestore_datasource.dart';
import '../datasources/device_remote_datasource.dart';
import '../../domain/entities/device_info.dart';
import '../../domain/entities/system_status.dart';
import '../../domain/repositories/device_repository.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDataSource remoteDataSource;
  final DeviceFirestoreDataSource? firestoreDataSource;

  DeviceRepositoryImpl(
      this.remoteDataSource, {
        this.firestoreDataSource,
      });

  @override
  Future<DeviceInfo> getDeviceInfo() async {
    try {
      final deviceInfo = await remoteDataSource.getDeviceInfo();

      // Sauvegarder dans Firestore
      if (firestoreDataSource != null) {
        firestoreDataSource!.saveDeviceInfo(deviceInfo).catchError((e) {
          print('⚠️ Failed to save device info to Firestore: $e');
        });
      }

      return deviceInfo;
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<SystemStatus> getSystemStatus() async {
    try {
      return await remoteDataSource.getSystemStatus();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }
}