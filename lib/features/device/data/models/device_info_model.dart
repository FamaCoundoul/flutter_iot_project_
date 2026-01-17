import '../../domain/entities/device_info.dart';

class DeviceInfoModel extends DeviceInfo {
  const DeviceInfoModel({
    required super.deviceId,
    required super.deviceName,
    required super.location,
    required super.ip,
    required super.mac,
    required super.rssi,
    required super.ssid,
    required super.uptime,
    required super.freeHeap,
    required super.firmwareVersion,
    required super.chipModel,
    required super.cpuFreq,
    super.sensors,
    super.timestamp, super.receivedAt,
  });

  factory DeviceInfoModel.fromJson(Map<String, dynamic> json) {

    final int receivedAt;

    // Parser les capteurs si présents
    List<Map<String, dynamic>>? sensors;
    if (json['sensors'] != null) {
      sensors = (json['sensors'] as List)
          .map((s) => Map<String, dynamic>.from(s))
          .toList();
    }

    return DeviceInfoModel(
      deviceId: json['deviceId'] as String,
      deviceName: json['deviceName'] as String,
      location: json['location'] as String,
      ip: json['ip'] as String,
      mac: json['mac'] as String,
      rssi: json['rssi'] as int,
      ssid: json['ssid'] as String,
      uptime: json['uptime'] as int,
      freeHeap: json['freeHeap'] as int,
      firmwareVersion: json['firmwareVersion'] as String,
      chipModel: json['chipModel'] as String,
      cpuFreq: json['cpuFreq'] as int,
      sensors: sensors,
      timestamp: json['timestamp'] as int?,
      receivedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'location': location,
      'ip': ip,
      'mac': mac,
      'rssi': rssi,
      'ssid': ssid,
      'uptime': uptime,
      'freeHeap': freeHeap,
      'firmwareVersion': firmwareVersion,
      'chipModel': chipModel,
      'cpuFreq': cpuFreq,
      if (sensors != null) 'sensors': sensors,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }
}