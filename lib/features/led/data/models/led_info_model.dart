import '../../domain/entities/led_info.dart';

class LedInfoModel extends LedInfo {
  const LedInfoModel({
    required super.status,
    required super.state,
    super.timestamp,
    super.mode,
  });

  factory LedInfoModel.fromJson(Map<String, dynamic> json) {
    return LedInfoModel(
      status: json['status'] as String,
      state: json['state'] as bool,
      timestamp: json['timestamp'] as int?,
      mode: json['mode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'state': state,
      if (timestamp != null) 'timestamp': timestamp,
      if (mode != null) 'mode': mode,
    };
  }
}