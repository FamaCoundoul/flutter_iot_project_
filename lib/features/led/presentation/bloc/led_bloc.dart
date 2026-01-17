import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/control_led.dart';
import '../../domain/usecases/get_led_status.dart';
import 'led_event.dart';
import 'led_state.dart';

class LedBloc extends Bloc<LedEvent, LedState> {
  final GetLedStatus getLedStatus;
  final ControlLed controlLed;

  LedBloc({
    required this.getLedStatus,
    required this.controlLed,
  }) : super(LedInitial()) {
    on<LoadLedStatus>(_onLoadLedStatus);
    on<ToggleLed>(_onToggleLed);
    on<TurnOnLed>(_onTurnOnLed);
    on<TurnOffLed>(_onTurnOffLed);
  }

  Future<void> _onLoadLedStatus(
      LoadLedStatus event,
      Emitter<LedState> emit,
      ) async {
    emit(LedLoading());
    try {
      final ledInfo = await getLedStatus();
      emit(LedLoaded(ledInfo: ledInfo));
    } catch (e) {
      emit(LedError(message: e.toString()));
    }
  }

  Future<void> _onToggleLed(
      ToggleLed event,
      Emitter<LedState> emit,
      ) async {
    try {
      await controlLed.toggle();
      // Recharger le statut après l'action
      final ledInfo = await getLedStatus();
      emit(LedLoaded(ledInfo: ledInfo));
    } catch (e) {
      emit(LedError(message: e.toString()));
    }
  }

  Future<void> _onTurnOnLed(
      TurnOnLed event,
      Emitter<LedState> emit,
      ) async {
    try {
      await controlLed.turnOn();
      // Recharger le statut après l'action
      final ledInfo = await getLedStatus();
      emit(LedLoaded(ledInfo: ledInfo));
    } catch (e) {
      emit(LedError(message: e.toString()));
    }
  }

  Future<void> _onTurnOffLed(
      TurnOffLed event,
      Emitter<LedState> emit,
      ) async {
    try {
      await controlLed.turnOff();
      // Recharger le statut après l'action
      final ledInfo = await getLedStatus();
      emit(LedLoaded(ledInfo: ledInfo));
    } catch (e) {
      emit(LedError(message: e.toString()));
    }
  }
}