import 'package:equatable/equatable.dart';

/// Events for ThresholdsBloc.
sealed class ThresholdsEvent extends Equatable {
  const ThresholdsEvent();

  @override
  List<Object?> get props => [];
}

/// Load thresholds from ESP32.
final class ThresholdsStarted extends ThresholdsEvent {
  const ThresholdsStarted();
}

/// Update local (UI) temperature threshold value.
final class TempThresholdChanged extends ThresholdsEvent {
  final double value;
  const TempThresholdChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// Toggle temperature threshold enabled.
final class TempEnabledChanged extends ThresholdsEvent {
  final bool enabled;
  const TempEnabledChanged(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Persist temperature threshold config (POST /api/thresholds).
final class TempSaveRequested extends ThresholdsEvent {
  const TempSaveRequested();
}

/// Update local (UI) light threshold value.
final class LightThresholdChanged extends ThresholdsEvent {
  final double value;
  const LightThresholdChanged(this.value);

  @override
  List<Object?> get props => [value];
}

/// Toggle light threshold enabled.
final class LightEnabledChanged extends ThresholdsEvent {
  final bool enabled;
  const LightEnabledChanged(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Persist light threshold config (POST /api/thresholds).
final class LightSaveRequested extends ThresholdsEvent {
  const LightSaveRequested();
}
