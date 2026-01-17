// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/sensors/presentation/bloc/sensors_bloc.dart';
import '../features/sensors/presentation/bloc/sensors_event.dart';
import '../features/led/presentation/bloc/led_bloc.dart';
import '../features/led/presentation/bloc/led_event.dart';
import '../features/device/presentation/bloc/device_bloc.dart';
import '../features/device/presentation/bloc/device_event.dart';

import '../shared/presentation/pages/shell_page.dart';
import '../theme/theme.dart';
import '../theme/util.dart';
import 'di.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(context, "Nunito Sans", "Nunito Sans");
    final materialTheme = MaterialTheme(textTheme);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<SensorsBloc>()..add(LoadSensors()),
        ),
        BlocProvider(
          create: (_) => getIt<LedBloc>()..add(LoadLedStatus()),
        ),
        BlocProvider(
          create: (_) => getIt<DeviceBloc>()..add(LoadDeviceInfo()),
        ),
      ],
      child: MaterialApp(
        title: 'IoT Sensor Dashboard',
        debugShowCheckedModeBanner: false,

        // Intégration du thème (light/dark) + mode système
        theme: materialTheme.light(),
        darkTheme: materialTheme.dark(),
        themeMode: ThemeMode.system,

        home: const ShellPage(),
      ),
    );
  }
}
