import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_iot_project/features/sensors/presentation/bloc/sensors_event.dart';
import 'package:flutter_iot_project/features/sensors/presentation/bloc/sensors_state.dart';
import 'package:flutter_iot_project/model/sensor.dart';

import '../../domain/usecases/get_sensors.dart';

class SensorsBloc extends Bloc<SensorsEvent, SensorsState> {
  final GetSensors getSensors;

  SensorsBloc({
    required this.getSensors,
  }) : super(SensorsInitial()) {
    on<LoadSensors>(_onLoadSensors);
    on<RefreshSensors>(_onRefreshSensors);
  }

  Future<void> _onLoadSensors(
      LoadSensors event,
      Emitter<SensorsState> emit,
      ) async {
    emit(SensorsLoading());

    try {
      final sensors = await getSensors();
      emit(SensorsLoaded(sensors.cast<Sensor>()));
    } catch (e) {
      emit(SensorsError('Erreur de chargement: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshSensors(
      RefreshSensors event,
      Emitter<SensorsState> emit,
      ) async {
    try {
      final sensors = await getSensors();
      emit(SensorsLoaded(sensors.cast<Sensor>()));
    } catch (e) {
      emit(SensorsError('Erreur de rafraîchissement: ${e.toString()}'));
    }
  }
}
























