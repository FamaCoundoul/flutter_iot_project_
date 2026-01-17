import 'package:bloc/bloc.dart';

import '../../domain/entities/threshold.dart';
import '../../domain/usecases/get_thresholds.dart';
import '../../domain/usecases/update_threshold.dart';
import 'thresholds_event.dart';
import 'thresholds_state.dart';

class ThresholdsBloc extends Bloc<ThresholdsEvent, ThresholdsState> {
  final GetThresholds getThresholds;
  final UpdateThreshold updateThreshold;

  ThresholdsBloc({required this.getThresholds, required this.updateThreshold})
    : super(ThresholdsState.initial()) {
    on<ThresholdsStarted>(_onStarted);
    on<TempThresholdChanged>(
      (e, emit) =>
          emit(state.copyWith(tempThreshold: e.value, clearMessage: true)),
    );
    on<TempEnabledChanged>(
      (e, emit) =>
          emit(state.copyWith(tempEnabled: e.enabled, clearMessage: true)),
    );
    on<LightThresholdChanged>(
      (e, emit) =>
          emit(state.copyWith(lightThreshold: e.value, clearMessage: true)),
    );
    on<LightEnabledChanged>(
      (e, emit) =>
          emit(state.copyWith(lightEnabled: e.enabled, clearMessage: true)),
    );
    on<TempSaveRequested>(_onTempSave);
    on<LightSaveRequested>(_onLightSave);
  }

  Future<void> _onStarted(
    ThresholdsStarted event,
    Emitter<ThresholdsState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearMessage: true));
    try {
      final list = await getThresholds();
      final temp = _findByType(list, 'temperature');
      final light = _findByType(list, 'light');

      emit(
        state.copyWith(
          loading: false,
          tempThreshold: temp?.threshold ?? state.tempThreshold,
          tempEnabled: temp?.enabled ?? state.tempEnabled,
          lightThreshold: light?.threshold ?? state.lightThreshold,
          lightEnabled: light?.enabled ?? state.lightEnabled,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          message: e.toString(),
          isErrorMessage: true,
        ),
      );
    }
  }

  Future<void> _onTempSave(
    TempSaveRequested event,
    Emitter<ThresholdsState> emit,
  ) async {
    emit(state.copyWith(savingTemp: true, clearMessage: true));
    try {
      final updated = await updateThreshold(
        sensorType: 'temperature',
        threshold: state.tempThreshold,
        enabled: state.tempEnabled,
      );
      emit(
        state.copyWith(
          savingTemp: false,
          tempThreshold: updated.threshold,
          tempEnabled: updated.enabled,
          message: 'Seuil température mis à jour',
          isErrorMessage: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          savingTemp: false,
          message: e.toString(),
          isErrorMessage: true,
        ),
      );
    }
  }

  Future<void> _onLightSave(
    LightSaveRequested event,
    Emitter<ThresholdsState> emit,
  ) async {
    emit(state.copyWith(savingLight: true, clearMessage: true));
    try {
      final updated = await updateThreshold(
        sensorType: 'light',
        threshold: state.lightThreshold,
        enabled: state.lightEnabled,
      );
      emit(
        state.copyWith(
          savingLight: false,
          lightThreshold: updated.threshold,
          lightEnabled: updated.enabled,
          message: 'Seuil lumière mis à jour',
          isErrorMessage: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          savingLight: false,
          message: e.toString(),
          isErrorMessage: true,
        ),
      );
    }
  }

  Threshold? _findByType(List<Threshold> list, String type) {
    for (final t in list) {
      if (t.sensorType == type) return t;
    }
    return null;
  }
}
