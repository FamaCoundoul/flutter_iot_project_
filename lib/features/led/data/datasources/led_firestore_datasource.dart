import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/led_info_model.dart';

abstract class LedFirestoreDataSource {
  Future<void> saveLedStatus(LedInfoModel ledInfo);
  Future<LedInfoModel?> getLastLedStatus();
  Stream<LedInfoModel> streamLedStatus();
}

class LedFirestoreDataSourceImpl implements LedFirestoreDataSource {
  final FirebaseFirestore firestore;

  LedFirestoreDataSourceImpl(this.firestore);

  @override
  Future<void> saveLedStatus(LedInfoModel ledInfo) async {
    try {
      final data = ledInfo.toJson();
      data['timestamp'] = DateTime.now().millisecondsSinceEpoch;

      await firestore
          .collection(FirestoreConstants.ledStatusCollection)
          .add(data);

      print('✅ LED status saved to Firestore');
    } catch (e) {
      throw CacheException('Failed to save LED status: $e');
    }
  }

  @override
  Future<LedInfoModel?> getLastLedStatus() async {
    try {
      final snapshot = await firestore
          .collection(FirestoreConstants.ledStatusCollection)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return LedInfoModel.fromJson(snapshot.docs.first.data());
    } catch (e) {
      throw CacheException('Failed to get LED status: $e');
    }
  }

  @override
  Stream<LedInfoModel> streamLedStatus() {
    return firestore
        .collection(FirestoreConstants.ledStatusCollection)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        throw CacheException('No LED status found');
      }
      return LedInfoModel.fromJson(snapshot.docs.first.data());
    });
  }
}