import 'dart:convert';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/esp32_http_client.dart';
import '../models/device_info_model.dart';
import '../models/system_status_model.dart';

abstract class DeviceRemoteDataSource {
  Future<DeviceInfoModel> getDeviceInfo();
  Future<SystemStatusModel> getSystemStatus();
}

class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final ESP32HttpClient httpClient;

  DeviceRemoteDataSourceImpl(this.httpClient);

  @override
  Future<DeviceInfoModel> getDeviceInfo() async {
    try {
      final response = await httpClient.get('/api/device/info');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return DeviceInfoModel.fromJson(json);
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException.fromJson(json, response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get device info: $e');
    }
  }

  @override
  Future<SystemStatusModel> getSystemStatus() async {
    try {
      final response = await httpClient.get('/api/status');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return SystemStatusModel.fromJson(json);
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException.fromJson(json, response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get system status: $e');
    }
  }
}