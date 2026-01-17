import 'package:equatable/equatable.dart';

class LedInfo extends Equatable {
  final String status;
  final bool state;
  final int? timestamp;
  final String? mode;

  const LedInfo({
    required this.status,
    required this.state,
    this.timestamp,
    this.mode,
  });

  @override
  List<Object?> get props => [status, state, timestamp, mode];

  bool get isOn => state;
  bool get isOff => !state;
}