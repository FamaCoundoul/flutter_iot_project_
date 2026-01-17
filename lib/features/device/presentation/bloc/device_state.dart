import 'package:equatable/equatable.dart';
import '../../domain/entities/device_info.dart';
import '../../domain/entities/system_status.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object?> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

// État principal avec les infos du device
class DeviceLoaded extends DeviceState {
  final DeviceInfo deviceInfo;

  const DeviceLoaded({required this.deviceInfo});

  @override
  List<Object?> get props => [deviceInfo];
}

// État pour les stats système (utilisé dans StatsCard)
class SystemStatusLoaded extends DeviceState {
  final SystemStatus systemStatus;

  const SystemStatusLoaded({required this.systemStatus});

  @override
  List<Object?> get props => [systemStatus];
}

class DeviceError extends DeviceState {
  final String message;

  const DeviceError({required this.message});

  @override
  List<Object?> get props => [message];
}