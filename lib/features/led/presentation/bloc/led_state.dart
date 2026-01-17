import 'package:equatable/equatable.dart';
import '../../domain/entities/led_info.dart';

abstract class LedState extends Equatable {
  const LedState();

  @override
  List<Object?> get props => [];
}

class LedInitial extends LedState {}

class LedLoading extends LedState {}

class LedLoaded extends LedState {
  final LedInfo ledInfo;

  const LedLoaded({required this.ledInfo});

  @override
  List<Object?> get props => [ledInfo];
}

class LedError extends LedState {
  final String message;

  const LedError({required this.message});

  @override
  List<Object?> get props => [message];
}