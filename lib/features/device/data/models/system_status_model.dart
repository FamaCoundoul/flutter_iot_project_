import '../../domain/entities/system_status.dart';

class SystemStatusModel extends SystemStatus {
  const SystemStatusModel({
    required super.uptime,
    required super.ledStatus,
    required super.sensorCount,
    required super.freeHeap,
    required super.timestamp, required super.lastUpdate,
  });

  factory SystemStatusModel.fromJson(Map<String, dynamic> json) {
    return SystemStatusModel(
      uptime: json['uptime'] as int,
      ledStatus: json['ledStatus'] as String,
      sensorCount: json['sensorCount'] as int,
      freeHeap: json['freeHeap'] as int,
      timestamp: json['timestamp'] as int,
      lastUpdate: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uptime': uptime,
      'ledStatus': ledStatus,
      'sensorCount': sensorCount,
      'freeHeap': freeHeap,
      'timestamp': timestamp,
    };
  }
}