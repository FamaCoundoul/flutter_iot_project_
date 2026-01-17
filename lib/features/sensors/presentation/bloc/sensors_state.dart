import 'package:equatable/equatable.dart';

import '../../../../model/sensor.dart';

abstract class SensorsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SensorsInitial extends SensorsState {}

class SensorsLoading extends SensorsState {}

class SensorsLoaded extends SensorsState {
  final List<Sensor> sensors;

  SensorsLoaded(this.sensors);

  @override
  List<Object?> get props => [sensors];
}

class SensorsError extends SensorsState {
  final String message;

  SensorsError(this.message);

  @override
  List<Object?> get props => [message];
}