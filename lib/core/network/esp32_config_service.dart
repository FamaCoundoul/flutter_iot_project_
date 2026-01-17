import 'package:shared_preferences/shared_preferences.dart';

/// Service pour gérer la configuration de l'ESP32
class ESP32ConfigService {
  static const String _baseUrlKey = 'esp32_base_url';
  static const String _defaultBaseUrl = 'http://172.20.10.6';

  final SharedPreferences _prefs;

  ESP32ConfigService(this._prefs);

  /// Récupère l'URL de base de l'ESP32
  String getBaseUrl() {
    return _prefs.getString(_baseUrlKey) ?? _defaultBaseUrl;
  }

  /// Sauvegarde l'URL de base de l'ESP32
  Future<bool> saveBaseUrl(String baseUrl) async {
    return await _prefs.setString(_baseUrlKey, baseUrl);
  }

  /// Vérifie si une URL a déjà été configurée
  bool hasConfiguredUrl() {
    return _prefs.containsKey(_baseUrlKey);
  }

  /// Réinitialise l'URL par défaut
  Future<bool> resetToDefault() async {
    return await _prefs.remove(_baseUrlKey);
  }

  /// Valide le format de l'URL
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;

    // Doit commencer par http:// ou https://
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      return false;
    }

    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Formate l'URL (ajoute http:// si nécessaire)
  static String formatUrl(String input) {
    String url = input.trim();

    // Si c'est juste une IP, ajoute http://
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'http://$url';
    }

    // Retire le slash final si présent
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    return url;
  }
}