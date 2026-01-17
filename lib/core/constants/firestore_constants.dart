class FirestoreConstants {
  // Collections
  static const String sensorsCollection = 'sensors';
  static const String ledStatusCollection = 'led_status';
  static const String systemStatusCollection = 'system_status';
  static const String thresholdsCollection = 'thresholds';
  static const String deviceInfoCollection = 'device_info';


  // Document IDs
  static const String currentDeviceInfoDoc = 'current';

  // Limites de données
  static const int maxHistoryRecords = 1000;
  static const int defaultQueryLimit = 50;
}

class FirestoreCollections {
  static const deviceReadings = 'device_readings';
  static const deviceSettings = 'device_settings';
  static const fcmTokens = 'fcm_tokens';
  static const alerts = 'alerts';
}

class FirestorePaths {
  static String settingsDoc(String deviceId) =>
      '${FirestoreCollections.deviceSettings}/$deviceId';

  static String readingsItemsCol(String deviceId) =>
      '${FirestoreCollections.deviceReadings}/$deviceId/items';

  static String tokenDoc(String token) =>
      '${FirestoreCollections.fcmTokens}/$token';
}