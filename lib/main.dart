import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iot_project/services/notification_manager.dart';
import 'app/app.dart';
import 'app/di.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'firebase_options.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('✅ Firebase initialized');

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Setup Dependency Injection
  setupDI();

  // Setup BLoC Observer pour debugging
  Bloc.observer = AppBlocObserver();

  // ✅ Initialiser les notifications
  await NotificationManager().initialize();


  runApp(const MyApp());
}