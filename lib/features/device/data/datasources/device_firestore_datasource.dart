import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/system_status_model.dart';
import '../models/device_info_model.dart';

abstract class DeviceFirestoreDataSource {
  Future<void> saveSystemStatus(SystemStatusModel status);
  Future<void> saveDeviceInfo(DeviceInfoModel deviceInfo);
  Future<SystemStatusModel?> getLastSystemStatus();
  Future<DeviceInfoModel?> getDeviceInfo();
}

class DeviceFirestoreDataSourceImpl implements DeviceFirestoreDataSource {
  final FirebaseFirestore firestore;

  DeviceFirestoreDataSourceImpl(this.firestore);

  @override
  Future<void> saveSystemStatus(SystemStatusModel status) async {
    try {
      final data = status.toJson();
      data['timestamp'] = DateTime.now().millisecondsSinceEpoch;

      await firestore
          .collection(FirestoreConstants.systemStatusCollection)
          .add(data);

      print('✅ System status saved to Firestore');
    } catch (e) {
      throw CacheException('Failed to save system status: $e');
    }
  }

  @override
  Future<void> saveDeviceInfo(DeviceInfoModel deviceInfo) async {
    try {
      final data = deviceInfo.toJson();
      data['lastUpdate'] = DateTime.now().millisecondsSinceEpoch;

      await firestore
          .collection(FirestoreConstants.deviceInfoCollection)
          .doc(FirestoreConstants.currentDeviceInfoDoc)
          .set(data, SetOptions(merge: true));

      print('✅ Device info saved to Firestore');
    } catch (e) {
      throw CacheException('Failed to save device info: $e');
    }
  }

  @override
  Future<SystemStatusModel?> getLastSystemStatus() async {
    try {
      final snapshot = await firestore
          .collection(FirestoreConstants.systemStatusCollection)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return SystemStatusModel.fromJson(snapshot.docs.first.data());
    } catch (e) {
      throw CacheException('Failed to get system status: $e');
    }
  }

  @override
  Future<DeviceInfoModel?> getDeviceInfo() async {
    try {
      final doc = await firestore
          .collection(FirestoreConstants.deviceInfoCollection)
          .doc(FirestoreConstants.currentDeviceInfoDoc)
          .get();

      if (!doc.exists) return null;

      return DeviceInfoModel.fromJson(doc.data()!);
    } catch (e) {
      throw CacheException('Failed to get device info: $e');
    }
  }
}