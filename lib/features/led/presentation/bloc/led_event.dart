import 'package:equatable/equatable.dart';

abstract class LedEvent extends Equatable {
  const LedEvent();

  @override
  List<Object?> get props => [];
}

class LoadLedStatus extends LedEvent {}

class ToggleLed extends LedEvent {}

class TurnOnLed extends LedEvent {}

class TurnOffLed extends LedEvent {}