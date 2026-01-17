import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/exceptions.dart';

abstract class ThresholdsFirestoreDataSource {
  Future<void> saveThreshold({
    required String sensorType,
    required double threshold,
    required bool enabled,
  });
  Future<List<Map<String, dynamic>>> getThresholds();
}

class ThresholdsFirestoreDataSourceImpl implements ThresholdsFirestoreDataSource {
  final FirebaseFirestore firestore;

  ThresholdsFirestoreDataSourceImpl(this.firestore);

  @override
  Future<void> saveThreshold({
    required String sensorType,
    required double threshold,
    required bool enabled,
  }) async {
    try {
      final data = {
        'sensorType': sensorType,
        'threshold': threshold,
        'enabled': enabled,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      await firestore
          .collection(FirestoreConstants.thresholdsCollection)
          .add(data);

      print('✅ Threshold saved to Firestore');
    } catch (e) {
      throw CacheException('Failed to save threshold: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getThresholds() async {
    try {
      final snapshot = await firestore
          .collection(FirestoreConstants.thresholdsCollection)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw CacheException('Failed to get thresholds: $e');
    }
  }
}