import 'dart:convert';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/esp32_http_client.dart';
import '../models/led_info_model.dart';

abstract class LedRemoteDataSource {
  Future<LedInfoModel> getLedInfo();
  Future<void> setLedAction(String action);
}

class LedRemoteDataSourceImpl implements LedRemoteDataSource {
  final ESP32HttpClient httpClient;

  LedRemoteDataSourceImpl(this.httpClient);

  @override
  Future<LedInfoModel> getLedInfo() async {
    try {
      final response = await httpClient.get('/api/led');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return LedInfoModel.fromJson(json);
      } else {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException.fromJson(json, response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to get LED info: $e');
    }
  }

  @override
  Future<void> setLedAction(String action) async {
    try {
      final response = await httpClient.post('/api/led', {'action': action});

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException.fromJson(json, response.statusCode);
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw NetworkException('Failed to set LED action: $e');
    }
  }
}