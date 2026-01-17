import 'package:equatable/equatable.dart';

class ThresholdsState extends Equatable {
  final bool loading;
  final bool savingTemp;
  final bool savingLight;

  final double tempThreshold;
  final bool tempEnabled;

  final double lightThreshold;
  final bool lightEnabled;

  /// Optional message for snackbars (success/errors).
  final String? message;
  final bool isErrorMessage;

  const ThresholdsState({
    required this.loading,
    required this.savingTemp,
    required this.savingLight,
    required this.tempThreshold,
    required this.tempEnabled,
    required this.lightThreshold,
    required this.lightEnabled,
    this.message,
    this.isErrorMessage = false,
  });

  factory ThresholdsState.initial() => const ThresholdsState(
    loading: false,
    savingTemp: false,
    savingLight: false,
    tempThreshold: 25.0,
    tempEnabled: true,
    lightThreshold: 2500.0,
    lightEnabled: false,
  );

  ThresholdsState copyWith({
    bool? loading,
    bool? savingTemp,
    bool? savingLight,
    double? tempThreshold,
    bool? tempEnabled,
    double? lightThreshold,
    bool? lightEnabled,
    String? message,
    bool? isErrorMessage,
    bool clearMessage = false,
  }) {
    return ThresholdsState(
      loading: loading ?? this.loading,
      savingTemp: savingTemp ?? this.savingTemp,
      savingLight: savingLight ?? this.savingLight,
      tempThreshold: tempThreshold ?? this.tempThreshold,
      tempEnabled: tempEnabled ?? this.tempEnabled,
      lightThreshold: lightThreshold ?? this.lightThreshold,
      lightEnabled: lightEnabled ?? this.lightEnabled,
      message: clearMessage ? null : (message ?? this.message),
      isErrorMessage: isErrorMessage ?? this.isErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
    loading,
    savingTemp,
    savingLight,
    tempThreshold,
    tempEnabled,
    lightThreshold,
    lightEnabled,
    message,
    isErrorMessage,
  ];
}
