import 'package:equatable/equatable.dart';

abstract class SensorsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadSensors extends SensorsEvent {}

class RefreshSensors extends SensorsEvent {}

class LoadSensorById extends SensorsEvent {
  final int id;

  LoadSensorById(this.id);

  @override
  List<Object?> get props => [id];
}