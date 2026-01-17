import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/presentation/widgets/app_header.dart';
import '../../../device/presentation/bloc/device_bloc.dart';
import '../../../device/presentation/bloc/device_event.dart';
import '../../../led/presentation/bloc/led_bloc.dart';
import '../../../led/presentation/bloc/led_event.dart';
import '../../../led/presentation/widgets/led_control_card.dart';
import '../../../sensors/presentation/bloc/sensors_bloc.dart';
import '../../../sensors/presentation/bloc/sensors_event.dart';
import '../../../sensors/presentation/bloc/sensors_state.dart';
import '../widgets/sensor_card.dart';
import '../widgets/stats_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _devicePoller;

  @override
  void initState() {
    super.initState();

    // Charger une première fois après le 1er frame (safe pour context.read)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceBloc>().add(LoadDeviceInfo());
      context.read<DeviceBloc>().add(LoadSystemStatus());
      context.read<SensorsBloc>().add(RefreshSensors());
      context.read<LedBloc>().add(LoadLedStatus());
    });

    // Poll toutes les 3 secondes uniquement pour DeviceInfo (IP / statut)
    _devicePoller = Timer.periodic(const Duration(seconds: 1000), (_) {
      if (!mounted) return;
      context.read<DeviceBloc>().add(LoadDeviceInfo());
    });
  }

  @override
  void dispose() {
    _devicePoller?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<DeviceBloc>().add(LoadDeviceInfo());
    context.read<DeviceBloc>().add(LoadSystemStatus());
    context.read<SensorsBloc>().add(RefreshSensors());
    context.read<LedBloc>().add(LoadLedStatus());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            const AppHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  BlocBuilder<SensorsBloc, SensorsState>(
                    builder: (context, state) {
                      if (state is SensorsLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (state is SensorsError) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (state is SensorsLoaded) {
                        final sensors = state.sensors;

                        final tempSensor = sensors.firstWhere(
                              (s) => s.isTemperature,
                          orElse: () => sensors.first,
                        );

                        final lightSensor = sensors.firstWhere(
                              (s) => s.isLight,
                          orElse: () => sensors.isNotEmpty ? sensors.last : tempSensor,
                        );

                        return Row(
                          children: [
                            Expanded(child: SensorCard(sensor: tempSensor)),
                            const SizedBox(width: 12),
                            Expanded(child: SensorCard(sensor: lightSensor)),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 16),
                  const LedControlCard(),
                  const SizedBox(height: 16),
                  const StatsCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
