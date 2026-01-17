class DeviceReading {
  final String deviceId;
  final int timestamp; // ms epoch
  final double temperature;
  final double light;
  final bool ledState;
  final String ip;

  const DeviceReading({
    required this.deviceId,
    required this.timestamp,
    required this.temperature,
    required this.light,
    required this.ledState,
    required this.ip,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'temperature': temperature,
    'light': light,
    'ledState': ledState,
    'ip': ip,
  };
}
