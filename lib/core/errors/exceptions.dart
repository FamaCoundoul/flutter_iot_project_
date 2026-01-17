/// Exception de base pour l'application
abstract class AppException implements Exception {
  final String message;
  final String? details;

  AppException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}

/// Exception réseau (pas de connexion, timeout, etc.)
class NetworkException extends AppException {
  NetworkException(String message, [String? details]) : super(message, details);
}

/// Exception API (erreur renvoyée par l'API)
class ApiException extends AppException {
  final int? statusCode;

  ApiException(String message, {this.statusCode, String? details})
      : super(message, details);

  factory ApiException.fromJson(Map<String, dynamic> json, int statusCode) {
    return ApiException(
      json['message'] ?? json['error'] ?? 'Unknown error',
      statusCode: statusCode,
      details: json['details'],
    );
  }
}

/// Exception de parsing
class ParseException extends AppException {
  ParseException(String message, [String? details]) : super(message, details);
}

/// Exception de cache
class CacheException extends AppException {
  CacheException(String message, [String? details]) : super(message, details);
}

/// Exception de validation
class ValidationException extends AppException {
  ValidationException(String message, [String? details]) : super(message, details);
}