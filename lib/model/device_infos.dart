
import 'package:flutter_iot_project/model/sensor_model.dart';

class DeviceInfo {
  String? deviceId;
  String? deviceName;
  String? location;
  String? ip;
  String? mac;
  int? rssi;
  String? ssid;
  List<SensorModel>? sensors;
  int? timestamp;

  DeviceInfo({
    this.deviceId,
    this.deviceName,
    this.location,
    this.ip,
    this.mac,
    this.rssi,
    this.ssid,
    this.sensors,
    this.timestamp,
  });

  DeviceInfo.fromJson(Map<String, dynamic> json) {
    deviceId = json['deviceId'];
    deviceName = json['deviceName'];
    location = json['location'];
    ip = json['ip'];
    mac = json['mac'];
    rssi = json['rssi'];
    ssid = json['ssid'];
    if (json['sensors'] != null) {
      sensors = <SensorModel>[];
      json['sensors'].forEach((v) {
        sensors!.add(SensorModel.fromJson(v));
      });
    }
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['deviceId'] = deviceId;
    data['deviceName'] = deviceName;
    data['location'] = location;
    data['ip'] = ip;
    data['mac'] = mac;
    data['rssi'] = rssi;
    data['ssid'] = ssid;
    if (sensors != null) {
      data['sensors'] = sensors!.map((v) => v.toJson()).toList();
    }
    data['timestamp'] = timestamp;
    return data;
  }
}
