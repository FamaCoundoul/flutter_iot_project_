import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Client HTTP pour communiquer avec l'API ESP32
class ESP32HttpClient {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  ESP32HttpClient({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  void dispose() => _client.close();

  /// GET request
  Future<http.Response> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      return await _client.get(uri).timeout(timeout);
    } on SocketException catch (e) {
      throw HttpException('No connection to ESP32: ${e.message}');
    } on TimeoutException {
      throw HttpException('Request timeout');
    }
  }

  /// POST request
  Future<http.Response> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      return await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(timeout);
    } on SocketException catch (e) {
      throw HttpException('No connection to ESP32: ${e.message}');
    } on TimeoutException {
      throw HttpException('Request timeout');
    }
  }

  /// Test connection
  Future<bool> testConnection() async {
    try {
      final response = await get('/api/status');
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  String get url => baseUrl;
}