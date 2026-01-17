import '../../domain/entities/sensor.dart';

class SensorModel extends Sensor {
  const SensorModel({
    required super.id,
    required super.name,
    required super.type,
    required super.value,
    required super.unit,
    super.minValue,
    super.maxValue,
    super.timestamp,
    super.lastRead,
  });

  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      minValue: json['minValue'] != null
          ? (json['minValue'] as num).toDouble()
          : null,
      maxValue: json['maxValue'] != null
          ? (json['maxValue'] as num).toDouble()
          : null,
      timestamp: json['timestamp'] as int?,
      lastRead: json['lastRead'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'unit': unit,
      if (minValue != null) 'minValue': minValue,
      if (maxValue != null) 'maxValue': maxValue,
      if (timestamp != null) 'timestamp': timestamp,
      if (lastRead != null) 'lastRead': lastRead,
    };
  }

  factory SensorModel.fromEntity(Sensor sensor) {
    return SensorModel(
      id: sensor.id,
      name: sensor.name,
      type: sensor.type,
      value: sensor.value,
      unit: sensor.unit,
      minValue: sensor.minValue,
      maxValue: sensor.maxValue,
      timestamp: sensor.timestamp,
      lastRead: sensor.lastRead,
    );
  }
}