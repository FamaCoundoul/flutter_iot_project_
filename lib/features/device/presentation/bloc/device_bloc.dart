import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_device_info.dart';
import '../../domain/usecases/get_system_status.dart';
import 'device_event.dart';
import 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final GetDeviceInfo getDeviceInfo;
  final GetSystemStatus getSystemStatus;

  DeviceBloc({
    required this.getDeviceInfo,
    required this.getSystemStatus,
  }) : super(DeviceInitial()) {
    on<LoadDeviceInfo>(_onLoadDeviceInfo);
    on<LoadSystemStatus>(_onLoadSystemStatus);
  }

  Future<void> _onLoadDeviceInfo(
      LoadDeviceInfo event,
      Emitter<DeviceState> emit,
      ) async {
    emit(DeviceLoading());
    try {
      final deviceInfo = await getDeviceInfo();
      emit(DeviceLoaded(deviceInfo: deviceInfo));
    } catch (e) {
      emit(DeviceError(message: e.toString()));
    }
  }

  Future<void> _onLoadSystemStatus(
      LoadSystemStatus event,
      Emitter<DeviceState> emit,
      ) async {
    emit(DeviceLoading());
    try {
      final systemStatus = await getSystemStatus();
      emit(SystemStatusLoaded(systemStatus: systemStatus));
    } catch (e) {
      emit(DeviceError(message: e.toString()));
    }
  }
}