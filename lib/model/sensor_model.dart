class SensorModel {
  final int? id;
  final String? name;
  final String? type;
  final double? value;
  final String? unit;
  final int? timestamp;
  final int? lastRead;
  final int? minValue;
  final int? maxValue;

  const SensorModel({
    this.id,
    this.name,
    this.type,
    this.value,
    this.unit,
    this.timestamp,
    this.lastRead,
    this.minValue,
    this.maxValue,
  });

  /// 🔁 JSON → Model
  factory SensorModel.fromJson(Map<String, dynamic> json) {
    return SensorModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      type: json['type'] as String?,
      value: (json['value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      timestamp: json['timestamp'] as int?,
      lastRead: json['lastRead'] as int?,
      minValue: json['minValue'] as int?,
      maxValue: json['maxValue'] as int?,
    );
  }

  /// 🔁 Model → JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'value': value,
      'unit': unit,
      'timestamp': timestamp,
      'lastRead': lastRead,
      'minValue': minValue,
      'maxValue': maxValue,
    };
  }

  /// 🔁 Copy utilitaire
  SensorModel copyWith({
    int? id,
    String? name,
    String? type,
    double? value,
    String? unit,
    int? timestamp,
    int? lastRead,
    int? minValue,
    int? maxValue,
  }) {
    return SensorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      lastRead: lastRead ?? this.lastRead,
      minValue: minValue ?? this.minValue,
      maxValue: maxValue ?? this.maxValue,
    );
  }
}
