import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/sensor_model.dart';

abstract class SensorsFirestoreDataSource {
  Future<void> saveSensorsData(List<SensorModel> sensors);
  Future<List<SensorModel>> getRecentSensors({int limit = 50});
  Stream<List<SensorModel>> streamRecentSensors({int limit = 10});
}

class SensorsFirestoreDataSourceImpl implements SensorsFirestoreDataSource {
  final FirebaseFirestore firestore;

  SensorsFirestoreDataSourceImpl(this.firestore);

  @override
  Future<void> saveSensorsData(List<SensorModel> sensors) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Créer un document avec toutes les données des capteurs
      final data = {
        'temperature': sensors.firstWhere((s) => s.type == 'temperature').value,
        'light': sensors.firstWhere((s) => s.type == 'light').value,
        'timestamp': timestamp,
        'deviceId': 'ESP32-TTGO', // Vous pouvez rendre ceci dynamique
        'sensors': sensors.map((s) => s.toJson()).toList(),
      };

      await firestore
          .collection(FirestoreConstants.sensorsCollection)
          .add(data);

      print('✅ Sensors data saved to Firestore');
    } catch (e) {
      throw CacheException('Failed to save sensors data: $e');
    }
  }

  @override
  Future<List<SensorModel>> getRecentSensors({int limit = 50}) async {
    try {
      final snapshot = await firestore
          .collection(FirestoreConstants.sensorsCollection)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      // Extraire les capteurs du premier document
      if (snapshot.docs.isEmpty) return [];

      final data = snapshot.docs.first.data();
      final sensorsData = data['sensors'] as List;

      return sensorsData
          .map((s) => SensorModel.fromJson(s as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Failed to get sensors data: $e');
    }
  }

  @override
  Stream<List<SensorModel>> streamRecentSensors({int limit = 10}) {
    return firestore
        .collection(FirestoreConstants.sensorsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return <SensorModel>[];

      final data = snapshot.docs.first.data();
      final sensorsData = data['sensors'] as List;

      return sensorsData
          .map((s) => SensorModel.fromJson(s as Map<String, dynamic>))
          .toList();
    });
  }
}