import 'dart:convert';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/esp32_http_client.dart';
import '../models/sensor_model.dart';

abstract class SensorsRemoteDataSource {
  Future<List<SensorModel>> getSensors();
  Future<SensorModel> getSensorById(int id);
}

class SensorsRemoteDataSourceImpl implements SensorsRemoteDataSource {
  final ESP32HttpClient httpClient;

  SensorsRemoteDataSourceImpl(this.httpClient);

  @override
  Future<List<SensorModel>> getSensors() async {
    try {
      final response = await httpClient.get('/api/sensors');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final sensorsJson = json['sensors'] as List;

        return sensorsJson
            .map((sensorJson) => SensorModel.fromJson(sensorJson))
            .toList();
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException.fromJson(json, response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get sensors: $e');
    }
  }

  @override
  Future<SensorModel> getSensorById(int id) async {
    try {
      final response = await httpClient.get('/api/sensor?id=$id');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SensorModel.fromJson(json);
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException.fromJson(json, response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get sensor: $e');
    }
  }
}