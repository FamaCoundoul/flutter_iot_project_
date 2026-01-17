import 'dart:convert';
import 'package:http/http.dart' as http;

class IpLocation {
  final String ip;
  final String? country;
  final String? region;
  final String? city;
  final double? lat;
  final double? lon;

  const IpLocation({
    required this.ip,
    this.country,
    this.region,
    this.city,
    this.lat,
    this.lon,
  });

  String get label {
    final parts = [city, region, country].where((e) => e != null && e!.isNotEmpty).toList();
    return parts.isEmpty ? 'Localisation inconnue' : parts.join(', ');
  }
}

class IpLocationService {
  // 1) IP publique
  Future<String> getPublicIp() async {
    // Service très simple
    final res = await http.get(Uri.parse('https://api.ipify.org?format=json'));
    if (res.statusCode != 200) throw Exception('Impossible de récupérer IP publique');
    final jsonMap = jsonDecode(res.body) as Map<String, dynamic>;
    return (jsonMap['ip'] as String);
  }

  // 2) Géolocalisation (approx)
  Future<IpLocation> locateFromPublicIp() async {
    final ip = await getPublicIp();

    // Exemple API: ipapi.co (simple)
    final res = await http.get(Uri.parse('https://ipapi.co/$ip/json/'));
    if (res.statusCode != 200) throw Exception('Impossible de géolocaliser IP');

    final m = jsonDecode(res.body) as Map<String, dynamic>;

    return IpLocation(
      ip: ip,
      country: (m['country_name'] as String?),
      region: (m['region'] as String?),
      city: (m['city'] as String?),
      lat: (m['latitude'] as num?)?.toDouble(),
      lon: (m['longitude'] as num?)?.toDouble(),
    );
  }
}
