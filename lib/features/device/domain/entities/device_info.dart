import 'package:equatable/equatable.dart';

class DeviceInfo extends Equatable {
  final String deviceId;
  final String deviceName;
  final String location;
  final String ip;
  final String mac;
  final int rssi;
  final String ssid;
  final int uptime;
  final int freeHeap;
  final String firmwareVersion;
  final String chipModel;
  final int cpuFreq;
  final List<Map<String, dynamic>>? sensors;
  final int? timestamp;
  final int? receivedAt;

  const DeviceInfo({
    required this.deviceId,
    required this.deviceName,
    required this.location,
    required this.ip,
    required this.mac,
    required this.rssi,
    required this.ssid,
    required this.uptime,
    required this.freeHeap,
    required this.firmwareVersion,
    required this.chipModel,
    required this.cpuFreq,
    this.sensors,
    this.timestamp,
    this.receivedAt,
  });

  bool isFresh({int maxDelayMs = 5000}) {
    if (receivedAt == null) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - receivedAt!) <= maxDelayMs;
  }
  @override
  List<Object?> get props => [
    deviceId,
    deviceName,
    location,
    ip,
    mac,
    rssi,
    ssid,
    uptime,
    freeHeap,
    firmwareVersion,
    chipModel,
    cpuFreq,
    sensors,
    timestamp,
    receivedAt,
  ];

  /// Indique si le device est connecté (basé sur le timestamp)
  bool get isConnected {
    if (timestamp == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - receivedAt!;

    // Considéré connecté si la dernière mise à jour < 10 secondes
    return diff < 10000;
  }

  /// Formatage du signal WiFi
  String get signalStrength {
    if (rssi >= -50) return 'Excellent';
    if (rssi >= -60) return 'Bon';
    if (rssi >= -70) return 'Moyen';
    return 'Faible';
  }

  /// Formatage de l'uptime
  String get uptimeFormatted {
    final seconds = uptime ~/ 1000;
    final minutes = seconds ~/ 60;
    final hours = minutes ~/ 60;
    final days = hours ~/ 24;

    if (days > 0) {
      return '${days}j ${hours % 24}h ${minutes % 60}m';
    } else if (hours > 0) {
      return '${hours}h ${minutes % 60}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds % 60}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Formatage de la mémoire
  String get freeHeapFormatted {
    if (freeHeap >= 1024 * 1024) {
      return '${(freeHeap / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else if (freeHeap >= 1024) {
      return '${(freeHeap / 1024).toStringAsFixed(2)} KB';
    } else {
      return '$freeHeap bytes';
    }
  }
}