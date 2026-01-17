import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/led_firestore_datasource.dart';
import '../datasources/led_remote_datasource.dart';
import '../../domain/entities/led_info.dart';
import '../../domain/repositories/led_repository.dart';

class LedRepositoryImpl implements LedRepository {
  final LedRemoteDataSource remoteDataSource;
  final LedFirestoreDataSource? firestoreDataSource;

  LedRepositoryImpl(
      this.remoteDataSource, {
        this.firestoreDataSource,
      });

  @override
  Future<LedInfo> getLedStatus() async {
    try {
      final ledInfo = await remoteDataSource.getLedInfo();

      // Sauvegarder dans Firestore
      if (firestoreDataSource != null) {
        firestoreDataSource!.saveLedStatus(ledInfo).catchError((e) {
          print('⚠️ Failed to save LED status to Firestore: $e');
        });
      }

      return ledInfo;
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<void> toggleLed() async {
    try {
      await remoteDataSource.setLedAction('toggle');
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<void> turnOnLed() async {
    try {
      await remoteDataSource.setLedAction('on');
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }

  @override
  Future<void> turnOffLed() async {
    try {
      await remoteDataSource.setLedAction('off');
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ApiException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Unexpected error: $e');
    }
  }
}