import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../../../app/di.dart';
import '../../../../core/firebase/iot_firebase_service.dart';
import '../../../../services/notification_manager.dart';
import '../../../../shared/presentation/widgets/app_header.dart';
import '../../../device/presentation/bloc/device_bloc.dart';
import '../../../device/presentation/bloc/device_event.dart';
import '../../../device/presentation/bloc/device_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _firebase = getIt<IoTFirebaseService>();

  bool _notificationsEnabled = true;
  final _notificationManager = NotificationManager();

  bool _loading = true;
  bool _saving = false;

  // ---- Localisation (via IP publique / WAN) ----
  bool _locLoading = false;
  String _locationSubtitle = 'Appuyez pour détecter (via IP)';
  String _location = 'Non définie'; // ✅ manquait (utilisé par Firebase)
  String? _lastPublicIp;
  double? _lastLat;
  double? _lastLon;

  // On garde low/high en double (RangeSlider)
  double _tempLow = 0;
  double _tempHigh = 35;
  double _lightLow = 200;
  double _lightHigh = 2000;

  bool _tempEnabled = true;
  bool _lightEnabled = true;

  Timer? _debounceSave;

  @override
  void initState() {
    super.initState();
    _loadNotificationState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Assure qu'on a deviceId/deviceInfo dispo
      context.read<DeviceBloc>().add(LoadDeviceInfo());
      _loadFromFirebase();
    });
  }

  @override
  void dispose() {
    _debounceSave?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers anti-crash RangeSlider
  // ---------------------------------------------------------------------------
  double _clamp(double v, double min, double max) {
    if (v < min) return min;
    if (v > max) return max;
    return v;
  }

  /// Garantit low <= high + clamp dans [min,max]
  RangeValues _safeRange({
    required double low,
    required double high,
    required double min,
    required double max,
  }) {
    final l = _clamp(low, min, max);
    final h = _clamp(high, min, max);
    if (l <= h) return RangeValues(l, h);
    return RangeValues(h, l); // swap
  }

  String get _deviceIdOrDefault {
    final s = context.read<DeviceBloc>().state;
    if (s is DeviceLoaded) return s.deviceInfo.deviceId;
    return 'ESP32_TTGO_001';
  }

  // ---------------------------------------------------------------------------
  // Firebase: load/save
  // ---------------------------------------------------------------------------
  Future<void> _loadFromFirebase() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final deviceId = _deviceIdOrDefault;

      final data = await _firebase.getDeviceSettings(deviceId);
      final thresholds = (data['thresholds'] as Map<String, dynamic>?) ?? {};

      // ✅ parse robuste (évite .toDouble() sur null/dynamic)
      final rawTempLow = (thresholds['tempLow'] as num?)?.toDouble() ?? 0.0;
      final rawTempHigh = (thresholds['tempHigh'] as num?)?.toDouble() ?? 35.0;
      final rawLightLow = (thresholds['lightLow'] as num?)?.toDouble() ?? 200.0;
      final rawLightHigh =
          (thresholds['lightHigh'] as num?)?.toDouble() ?? 2000.0;

      // ✅ normalisation (évite low > high et hors plage)
      final tempSafe =
      _safeRange(low: rawTempLow, high: rawTempHigh, min: -20, max: 60);
      final lightSafe =
      _safeRange(low: rawLightLow, high: rawLightHigh, min: 0, max: 4095);

      if (!mounted) return;
      setState(() {
        _notificationsEnabled = (data['notificationsEnabled'] as bool?) ?? false;
        _location = (data['location'] as String?) ?? 'Non définie';

        _tempLow = tempSafe.start;
        _tempHigh = tempSafe.end;
        _lightLow = lightSafe.start;
        _lightHigh = lightSafe.end;

        _tempEnabled = (thresholds['tempEnabled'] as bool?) ?? true;
        _lightEnabled = (thresholds['lightEnabled'] as bool?) ?? true;

        // (optionnel) si tu veux afficher la location sauvegardée au départ :
        if (_location != 'Non définie' && _location.isNotEmpty) {
          _locationSubtitle = _location;
        }

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _snack('❌ Erreur chargement Firebase: $e');
    }
  }

  void _scheduleSave() {
    _debounceSave?.cancel();
    _debounceSave = Timer(const Duration(milliseconds: 600), () async {
      await _saveToFirebase();
    });
  }

  Future<void> _saveToFirebase() async {
    if (!mounted) return;
    setState(() => _saving = true);

    try {
      // ✅ re-normalise avant sauvegarde
      final t = _safeRange(low: _tempLow, high: _tempHigh, min: -20, max: 60);
      final l =
      _safeRange(low: _lightLow, high: _lightHigh, min: 0, max: 4095);

      _tempLow = t.start;
      _tempHigh = t.end;
      _lightLow = l.start;
      _lightHigh = l.end;

      final deviceId = _deviceIdOrDefault;

      await _firebase.saveDeviceSettingsWithHistory(
        deviceId: deviceId,
        data: {
          'notificationsEnabled': _notificationsEnabled,
          'location': _location,
          'thresholds': {
            'tempLow': _tempLow,
            'tempHigh': _tempHigh,
            'lightLow': _lightLow,
            'lightHigh': _lightHigh,
            'tempEnabled': _tempEnabled,
            'lightEnabled': _lightEnabled,
          },
        },
      );

      _snack('✅ Réglages sauvegardés');
    } catch (e) {
      _snack('❌ Erreur sauvegarde: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadNotificationState() async {
    final enabled = await _notificationManager.loadNotificationState();
    if (!mounted) return;
    setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Activer les notifications
      final token = await _notificationManager.requestPermissionAndGetToken();

      if (token != null) {
        if (!mounted) return;
        setState(() => _notificationsEnabled = true);
        await _notificationManager.saveNotificationState(true);
        await _notificationManager.addTopic('device_esp32');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '🔔 Notifications activées\nToken: ${token.length > 20 ? token.substring(0, 20) : token}...',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      // Désactiver les notifications
      if (!mounted) return;
      setState(() => _notificationsEnabled = false);
      await _notificationManager.saveNotificationState(false);
      await _notificationManager.removeTopic('device_esp32');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔕 Notifications désactivées'),
        ),
      );
    }

    // (optionnel) si tu veux aussi enregistrer ce switch dans Firebase :
    _scheduleSave();
  }

  // ===========================================================================
  // 📍 Localisation via IP (WAN) — version corrigée et robuste
  // ===========================================================================
  Future<void> _refreshLocationFromIp() async {
    if (_locLoading) return;

    if (!mounted) return;
    setState(() {
      _locLoading = true;
      _locationSubtitle = 'Détection en cours…';
    });

    try {
      final res = await http
          .get(Uri.parse('https://ipwho.is/'))
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final Map<String, dynamic> jsonMap =
      json.decode(res.body) as Map<String, dynamic>;

      final bool success = (jsonMap['success'] as bool?) ?? false;
      if (!success) {
        final msg = (jsonMap['message'] as String?) ?? 'Localisation impossible';
        throw Exception(msg);
      }

      // 🔹 IP publique (WAN)
      final String? publicIp = (jsonMap['ip'] as String?)?.trim();

      // 🔹 Infos géographiques (approx)
      final String? city = (jsonMap['city'] as String?)?.trim();
      final String? region = (jsonMap['region'] as String?)?.trim();
      final String? country = (jsonMap['country'] as String?)?.trim();

      final double? lat = (jsonMap['latitude'] as num?)?.toDouble();
      final double? lon = (jsonMap['longitude'] as num?)?.toDouble();

      // 🔹 IP locale ESP32 (LAN) (vient de DeviceBloc)
      final deviceState = context.read<DeviceBloc>().state;
      final String? espLocalIp =
      (deviceState is DeviceLoaded) ? deviceState.deviceInfo.ip : null;

      final locationLabel = [
        if (city != null && city.isNotEmpty) city,
        if (region != null && region.isNotEmpty) region,
        if (country != null && country.isNotEmpty) country,
      ].join(', ');

      final label =
      locationLabel.isEmpty ? 'Localisation inconnue' : locationLabel;

      if (!mounted) return;
      setState(() {
        _lastPublicIp = publicIp;
        _lastLat = lat;
        _lastLon = lon;

        // Affiche LAN (ESP32) au lieu de WAN
        _locationSubtitle =
        'LAN ESP32: ${espLocalIp ?? "—"} • ${locationLabel.isEmpty ? "Localisation inconnue" : locationLabel}';

        _location = _locationSubtitle;
      });


      // ✅ si tu veux sauvegarder automatiquement la location en Firestore
      _scheduleSave();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationSubtitle = 'Erreur localisation (réessayer)';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Localisation via IP impossible : $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _locLoading = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            const AppHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThresholdsCard(),
                  const SizedBox(height: 16),

                  // Localisation (✅ seulement cette partie est dynamique)
                  _buildSettingsItem(
                    icon: Icons.location_on,
                    title: 'Localisation',
                    subtitle: _locationSubtitle,
                    trailing: _locLoading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.my_location),
                    onTap: _refreshLocationFromIp,
                  ),

                  _buildSettingsItem(
                    icon: Icons.notifications,
                    title: 'Notifications',
                    subtitle: 'Alertes basées sur vos seuils',
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: _toggleNotifications,
                      activeColor: Colors.green,
                    ),
                  ),

                  _buildSettingsItem(
                    icon: Icons.sync,
                    title: 'Synchronisation',
                    subtitle: 'Envoi des readings vers Firestore',
                    trailing: _saving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.cloud_done),
                    onTap: () => _snack(
                      '✅ Sync Firestore activée (device_readings/{deviceId}/items)',
                    ),
                  ),

                  const SizedBox(height: 16),
                  _buildDeviceInfoCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Seuils Automatiques',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Icon(Icons.tune, size: 22, color: Colors.blue),
              ],
            ),
            const SizedBox(height: 20),

            _buildRangeThreshold(
              title: 'Température',
              unit: '°C',
              enabled: _tempEnabled,
              min: -20,
              max: 60,
              lowValue: _tempLow,
              highValue: _tempHigh,
              color: Colors.deepOrange,
              onToggle: (v) {
                setState(() => _tempEnabled = v);
                _scheduleSave();
              },
              onChanged: (range) {
                setState(() {
                  _tempLow = range.start;
                  _tempHigh = range.end;
                });
                _scheduleSave();
              },
            ),

            const Divider(height: 32),

            _buildRangeThreshold(
              title: 'Lumière',
              unit: 'lux',
              enabled: _lightEnabled,
              min: 0,
              max: 4095,
              lowValue: _lightLow,
              highValue: _lightHigh,
              color: Colors.amber,
              onToggle: (v) {
                setState(() => _lightEnabled = v);
                _scheduleSave();
              },
              onChanged: (range) {
                setState(() {
                  _lightLow = range.start;
                  _lightHigh = range.end;
                });
                _scheduleSave();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeThreshold({
    required String title,
    required String unit,
    required bool enabled,
    required double min,
    required double max,
    required double lowValue,
    required double highValue,
    required Color color,
    required ValueChanged<bool> onToggle,
    required ValueChanged<RangeValues> onChanged,
  }) {
    // ✅ anti-crash
    final safe = _safeRange(low: lowValue, high: highValue, min: min, max: max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            Switch(
              value: enabled,
              onChanged: onToggle,
              activeColor: Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 6),

        Text(
          'Plage : ${safe.start.toInt()} $unit  →  ${safe.end.toInt()} $unit',
          style: TextStyle(
            fontSize: 13,
            color: enabled ? Colors.black87 : Colors.grey,
          ),
        ),
        const SizedBox(height: 6),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.25),
            thumbColor: color,
            rangeThumbShape:
            const RoundRangeSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: RangeSlider(
            values: safe,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: BlocBuilder<DeviceBloc, DeviceState>(
          builder: (context, state) {
            if (state is DeviceLoaded) {
              final d = state.deviceInfo;
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Informations Device',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.phone_android,
                          size: 24, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow('Device ID', d.deviceId),
                  _buildInfoRow('Adresse IP', d.ip),
                  _buildInfoRow('SSID', d.ssid),
                  _buildInfoRow(
                    'Signal',
                    '${d.rssi} dBm (${d.signalStrength})',
                    isLast: true,
                  ),
                ],
              );
            }

            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Informations Device',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.phone_android,
                        size: 24, color: Colors.blue),
                  ],
                ),
                const SizedBox(height: 15),
                const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 12),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
