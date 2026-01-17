import 'package:equatable/equatable.dart';

class Sensor extends Equatable {
  final int id;
  final String name;
  final String type;
  final double value;
  final String unit;
  final double? minValue;
  final double? maxValue;
  final int? timestamp;
  final int? lastRead;

  const Sensor({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.unit,
    this.minValue,
    this.maxValue,
    this.timestamp,
    this.lastRead,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    value,
    unit,
    minValue,
    maxValue,
    timestamp,
    lastRead,
  ];

  bool get isTemperature => type == 'temperature';
  bool get isLight => type == 'light';
  Sensor copyWith({
    int? id,
    String? name,
    String? type,
    double? value,
    String? unit,
    double? minValue,
    double? maxValue,
    int? timestamp,
    int? lastRead,
  }) {
    return Sensor(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
      timestamp: timestamp ?? this.timestamp,
      lastRead: lastRead ?? this.lastRead,
    );
  }
}