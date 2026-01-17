import 'dart:convert';
import 'package:flutter_iot_project/core/network/esp32_http_client.dart';

import '../models/threshold_model.dart';

/// Remote datasource that talks to ESP32 REST API.
///
/// Endpoints used:
/// - GET  /api/thresholds
/// - POST /api/thresholds
abstract class ThresholdsRemoteDataSource {
  Future<List<ThresholdModel>> getThresholds();

  Future<ThresholdModel> updateThreshold({
    required String sensorType,
    double? threshold,
    bool? enabled,
  });
}

class ThresholdsRemoteDataSourceImpl implements ThresholdsRemoteDataSource {
  final ESP32HttpClient client;

  ThresholdsRemoteDataSourceImpl(this.client);

  @override
  Future<List<ThresholdModel>> getThresholds() async {
    final res = await client.get('/api/thresholds');
    final json = _decode(res.body);

    if (!_isSuccess(res.statusCode)) {
      throw Exception(_extractError(json) ?? 'Failed to fetch thresholds');
    }

    final raw = json['thresholds'];
    if (raw is! List) return <ThresholdModel>[];

    return raw
        .whereType<Map<String, dynamic>>()
        .map(ThresholdModel.fromJson)
        .toList();
  }

  @override
  Future<ThresholdModel> updateThreshold({
    required String sensorType,
    double? threshold,
    bool? enabled,
  }) async {
    final body = <String, dynamic>{
      'sensorType': sensorType,
      if (threshold != null) 'threshold': threshold,
      if (enabled != null) 'enabled': enabled,
    };

    final res = await client.post('/api/thresholds', body);
    final json = _decode(res.body);

    if (!_isSuccess(res.statusCode)) {
      throw Exception(_extractError(json) ?? 'Failed to update threshold');
    }

    return ThresholdModel.fromJson(json);
  }

  bool _isSuccess(int code) => code >= 200 && code < 300;

  Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'data': decoded};
  }

  String? _extractError(Map<String, dynamic> json) {
    final e = json['error'];
    if (e == null) return null;
    final hint = json['hint'];
    if (hint == null) return e.toString();
    return '${e.toString()} (hint: ${hint.toString()})';
  }
}
