import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/firebase/iot_firebase_service.dart';
import '../core/network/esp32_http_client.dart';
import '../core/network/esp32_config_service.dart';

import '../features/sensors/data/datasources/sensors_remote_datasource.dart';
import '../features/sensors/data/datasources/sensors_firestore_datasource.dart';
import '../features/sensors/domain/repositories/sensors_repository.dart';
import '../features/sensors/data/repositories/sensors_repository_impl.dart';
import '../features/sensors/domain/usecases/get_sensors.dart';
import '../features/sensors/presentation/bloc/sensors_bloc.dart';

import '../features/led/data/datasources/led_remote_datasource.dart';
import '../features/led/data/datasources/led_firestore_datasource.dart';
import '../features/led/domain/repositories/led_repository.dart';
import '../features/led/data/repositories/led_repository_impl.dart';
import '../features/led/domain/usecases/get_led_status.dart';
import '../features/led/domain/usecases/control_led.dart';
import '../features/led/presentation/bloc/led_bloc.dart';

import '../features/device/data/datasources/device_remote_datasource.dart';
import '../features/device/data/datasources/device_firestore_datasource.dart';
import '../features/device/domain/repositories/device_repository.dart';
import '../features/device/data/repositories/device_repository_impl.dart';
import '../features/device/domain/usecases/get_device_info.dart';
import '../features/device/domain/usecases/get_system_status.dart';
import '../features/device/presentation/bloc/device_bloc.dart';

import '../features/thresholds/data/datasources/thresholds_remote_datasource.dart';
import '../features/thresholds/data/datasources/thresholds_firestore_datasource.dart';
import '../features/thresholds/domain/repositories/thresholds_repository.dart';
import '../features/thresholds/data/repositories/thresholds_repository_impl.dart';
import '../features/thresholds/domain/usecases/get_thresholds.dart';
import '../features/thresholds/domain/usecases/update_threshold.dart';
import '../features/thresholds/presentation/bloc/thresholds_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {





  // ============================================================================
  // CORE - SharedPreferences, Firebase & Config
  // ============================================================================


  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Firebase Firestore
  final firestore = FirebaseFirestore.instance;
  getIt.registerSingleton<FirebaseFirestore>(firestore);

  getIt.registerLazySingleton<ESP32ConfigService>(
        () => ESP32ConfigService(getIt()),
  );

  // HTTP Client - Utilisera l'URL configurée
  getIt.registerLazySingleton<ESP32HttpClient>(
        () {
      final configService = getIt<ESP32ConfigService>();
      return ESP32HttpClient(baseUrl: configService.getBaseUrl());
    },
  );

  // ============================================================================
  // FIREBASE IOT
  // ============================================================================
  getIt.registerLazySingleton<IoTFirebaseService>(() => IoTFirebaseService());


  // ============================================================================
  // SENSORS FEATURE
  // ============================================================================

  // Data Sources
  getIt.registerLazySingleton<SensorsRemoteDataSource>(
        () => SensorsRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<SensorsFirestoreDataSource>(
        () => SensorsFirestoreDataSourceImpl(getIt()),
  );

  // Repository
  getIt.registerLazySingleton<SensorsRepository>(
        () => SensorsRepositoryImpl(
      getIt(), // Remote
      firestoreDataSource: getIt(), // Firestore
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetSensors(getIt()));

  // BLoC
  getIt.registerFactory(
        () => SensorsBloc(
      getSensors: getIt(),
    ),
  );

  // ============================================================================
  // LED FEATURE
  // ============================================================================

  // Data Sources
  getIt.registerLazySingleton<LedRemoteDataSource>(
        () => LedRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<LedFirestoreDataSource>(
        () => LedFirestoreDataSourceImpl(getIt()),
  );

  // Repository
  getIt.registerLazySingleton<LedRepository>(
        () => LedRepositoryImpl(
      getIt(), // Remote
      firestoreDataSource: getIt(), // Firestore
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetLedStatus(getIt()));
  getIt.registerLazySingleton(() => ControlLed(getIt()));

  // BLoC
  getIt.registerFactory(
        () => LedBloc(
      getLedStatus: getIt(),
      controlLed: getIt(),
    ),
  );

  // ============================================================================
  // DEVICE FEATURE
  // ============================================================================

  // Data Sources
  getIt.registerLazySingleton<DeviceRemoteDataSource>(
        () => DeviceRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<DeviceFirestoreDataSource>(
        () => DeviceFirestoreDataSourceImpl(getIt()),
  );

  // Repository
  getIt.registerLazySingleton<DeviceRepository>(
        () => DeviceRepositoryImpl(
      getIt(), // Remote
      firestoreDataSource: getIt(), // Firestore
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetDeviceInfo(getIt()));
  getIt.registerLazySingleton(() => GetSystemStatus(getIt()));

  // BLoC
  getIt.registerFactory(
        () => DeviceBloc(
      getDeviceInfo: getIt(),
      getSystemStatus: getIt(),
    ),
  );

  // ============================================================================
  // THRESHOLDS FEATURE
  // ============================================================================

  // Data Sources
  getIt.registerLazySingleton<ThresholdsRemoteDataSource>(
        () => ThresholdsRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<ThresholdsFirestoreDataSource>(
        () => ThresholdsFirestoreDataSourceImpl(getIt()),
  );

  // Repository
  getIt.registerLazySingleton<ThresholdsRepository>(
        () => ThresholdsRepositoryImpl(
      getIt(), // Remote
      firestore: getIt(), // Firestore datasource (pas un Object)
    ),
  );


  // Use Cases
  getIt.registerLazySingleton(() => GetThresholds(getIt()));
  getIt.registerLazySingleton(() => UpdateThreshold(getIt()));

  // BLoC
  getIt.registerFactory(
        () => ThresholdsBloc(
      getThresholds: getIt(),
      updateThreshold: getIt(),
    ),
  );

  print('✅ Dependency Injection configurée avec Firebase');
}

/// Teste la connexion à l'ESP32
Future<bool> testESP32Connection() async {
  try {
    final client = getIt<ESP32HttpClient>();
    return await client.testConnection();
  } catch (e) {
    print('❌ Erreur test connexion: $e');
    return false;
  }
}

/// Met à jour l'URL de l'ESP32 et réinitialise le HTTP client
Future<void> updateESP32Url(String newUrl) async {
  // Dispose de l'ancien client
  if (getIt.isRegistered<ESP32HttpClient>()) {
    final oldClient = getIt<ESP32HttpClient>();
    oldClient.dispose();
    await getIt.unregister<ESP32HttpClient>();
  }

  // Enregistre le nouveau client avec la nouvelle URL
  getIt.registerLazySingleton<ESP32HttpClient>(
        () => ESP32HttpClient(baseUrl: newUrl),
  );

  print('✅ URL ESP32 mise à jour: $newUrl');
}

/// Retourne l'URL actuelle de l'ESP32
String getCurrentESP32Url() {
  final configService = getIt<ESP32ConfigService>();
  return configService.getBaseUrl();
}