import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
// Import pour sauvegarder les fichiers (fonctionne sur Web/Mobile/Desktop)
import 'dart:html' as html;
import 'dart:typed_data';

import '../../../../shared/presentation/widgets/app_header.dart';
import '../bloc/sensors_bloc.dart';
import '../bloc/sensors_event.dart';
import '../bloc/sensors_state.dart';
import '../../../led/presentation/bloc/led_bloc.dart';
import '../../../led/presentation/bloc/led_state.dart';
import '../../../device/presentation/bloc/device_bloc.dart';
import '../../../device/presentation/bloc/device_state.dart';

// Enum pour les formats d'affichage
enum DisplayFormat {
  json,
  dashboard,
  text,
  table,
}

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Format sélectionné
  DisplayFormat _selectedFormat = DisplayFormat.json;

  // Statistiques Firestore
  int _totalRecords = 0;
  double _dataSize = 0.0;
  DateTime? _lastSync;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadFirestoreStats();
    _setupRealtimeUpdates();
  }

  /// Charge les statistiques Firestore
  Future<void> _loadFirestoreStats() async {
    try {
      setState(() => _isLoadingStats = true);

      final sensorsSnapshot = await _firestore.collection('sensors').get();
      final ledSnapshot = await _firestore.collection('led_status').get();
      final deviceSnapshot = await _firestore.collection('device_info').get();

      final totalDocs = sensorsSnapshot.docs.length +
          ledSnapshot.docs.length +
          deviceSnapshot.docs.length;

      double estimatedSize = 0.0;
      for (var doc in sensorsSnapshot.docs) {
        estimatedSize += _estimateDocSize(doc.data());
      }
      for (var doc in ledSnapshot.docs) {
        estimatedSize += _estimateDocSize(doc.data());
      }
      for (var doc in deviceSnapshot.docs) {
        estimatedSize += _estimateDocSize(doc.data());
      }

      DateTime? lastUpdate;
      for (var doc in sensorsSnapshot.docs) {
        final timestamp = doc.data()['timestamp'];
        if (timestamp != null) {
          try {
            final date = DateTime.fromMillisecondsSinceEpoch(
              timestamp is int ? timestamp : int.parse(timestamp.toString()),
            );
            if (lastUpdate == null || date.isAfter(lastUpdate)) {
              lastUpdate = date;
            }
          } catch (e) {
            debugPrint('Erreur parsing timestamp: $e');
          }
        }
      }

      if (mounted) {
        setState(() {
          _totalRecords = totalDocs;
          _dataSize = estimatedSize / 1024 / 1024;
          _lastSync = lastUpdate;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Erreur chargement stats: $e');
      if (mounted) {
        setState(() => _isLoadingStats = false);
      }
    }
  }

  double _estimateDocSize(Map<String, dynamic> data) {
    try {
      final jsonString = jsonEncode(data);
      return jsonString.length.toDouble();
    } catch (e) {
      return 0.0;
    }
  }

  void _setupRealtimeUpdates() {
    _firestore.collection('sensors').snapshots().listen(
          (snapshot) {
        if (snapshot.docs.isNotEmpty && mounted) {
          _loadFirestoreStats();
        }
      },
      onError: (error) {
        debugPrint('Erreur StreamBuilder: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<SensorsBloc>().add(LoadSensors());
          await _loadFirestoreStats();
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          children: [
            const AppHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Card Données Temps Réel (format dynamique)
                  _buildRealtimeDataCard(),
                  const SizedBox(height: 16),

                  // Card Historique Firestore
                  _buildFirestoreHistoryCard(),
                  const SizedBox(height: 16),

                  // Card Formats d'affichage
                  _buildDisplayFormatsCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card affichant les données temps réel avec format dynamique
  Widget _buildRealtimeDataCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.sensors, size: 24, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Données Temps Réel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getFormatLabel(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (_selectedFormat == DisplayFormat.json)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () => _copyToClipboard(),
                    tooltip: 'Copier JSON',
                  ),
              ],
            ),
            const SizedBox(height: 15),

            // Affichage selon le format
            BlocBuilder<SensorsBloc, SensorsState>(
              builder: (context, sensorsState) {
                return BlocBuilder<LedBloc, LedState>(
                  builder: (context, ledState) {
                    return BlocBuilder<DeviceBloc, DeviceState>(
                      builder: (context, deviceState) {
                        if (sensorsState is SensorsLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (sensorsState is SensorsError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Erreur: ${sensorsState.message}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Afficher selon le format sélectionné
                        try {
                          switch (_selectedFormat) {
                            case DisplayFormat.json:
                              return _buildJsonView(sensorsState, ledState, deviceState);
                            case DisplayFormat.dashboard:
                              return _buildDashboardView(sensorsState, ledState, deviceState);
                            case DisplayFormat.text:
                              return _buildTextView(sensorsState, ledState, deviceState);
                            case DisplayFormat.table:
                              return _buildTableView(sensorsState, ledState, deviceState);
                          }
                        } catch (e) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Icon(Icons.error_outline, size: 48, color: Colors.orange),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Erreur affichage: $e',
                                    style: const TextStyle(color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Vue JSON (format original)
  Widget _buildJsonView(
      SensorsState sensorsState,
      LedState ledState,
      DeviceState deviceState,
      ) {
    final jsonData = _buildJsonData(sensorsState, ledState, deviceState);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF282c34),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          _formatJson(jsonData),
          style: const TextStyle(
            fontFamily: 'Courier',
            fontSize: 12,
            color: Color(0xFFabb2bf),
            height: 1.5,
          ),
        ),
      ),
    );
  }

  /// Vue Dashboard (cartes visuelles)
  Widget _buildDashboardView(
      SensorsState sensorsState,
      LedState ledState,
      DeviceState deviceState,
      ) {
    return Column(
      children: [
        // Capteurs
        if (sensorsState is SensorsLoaded && sensorsState.sensors.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: _buildSensorCard(
                  'Température',
                  _getSensorValue(sensorsState, 'temperature'),
                  '°C',
                  Icons.thermostat,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSensorCard(
                  'Lumière',
                  _getSensorValue(sensorsState, 'light'),
                  'lux',
                  Icons.light_mode,
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        // LED
        if (ledState is LedLoaded)
          _buildStatusCard(
            'État LED',
            ledState.ledInfo.state ? 'Allumée' : 'Éteinte',
            ledState.ledInfo.state ? Icons.lightbulb : Icons.lightbulb_outline,
            ledState.ledInfo.state ? Colors.green : Colors.grey,
          ),

        // Device
        if (deviceState is DeviceLoaded) ...[
          const SizedBox(height: 12),
          _buildStatusCard(
            'Connexion',
            deviceState.deviceInfo.isConnected ? 'Connecté' : 'Connecté',
            Icons.wifi,
            deviceState.deviceInfo.isConnected ? Colors.green : Colors.green,
          ),
        ],

        // Message si aucune donnée
        if (sensorsState is! SensorsLoaded ||
            sensorsState.sensors.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Aucune donnée capteur disponible',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  String _getSensorValue(SensorsLoaded state, String type) {
    try {
      final sensor = state.sensors.firstWhere(
            (s) => s.type == type,
        orElse: () => state.sensors.first,
      );

      if (type == 'light') {
        return sensor.value.toInt().toString();
      } else {
        return sensor.value.toStringAsFixed(1);
      }
    } catch (e) {
      return '0.0';
    }
  }

  /// Vue Texte (format lisible)
  Widget _buildTextView(
      SensorsState sensorsState,
      LedState ledState,
      DeviceState deviceState,
      ) {
    final buffer = StringBuffer();

    buffer.writeln('=== DONNÉES TEMPS RÉEL ===\n');
    buffer.writeln('Horodatage: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}\n');

    if (sensorsState is SensorsLoaded && sensorsState.sensors.isNotEmpty) {
      buffer.writeln('--- CAPTEURS ---');
      for (var sensor in sensorsState.sensors) {
        try {
          buffer.writeln('${sensor.name}: ${sensor.value.toStringAsFixed(2)} ${sensor.unit}');
        } catch (e) {
          buffer.writeln('${sensor.name}: N/A ${sensor.unit}');
        }
      }
      buffer.writeln();
    }

    if (ledState is LedLoaded) {
      buffer.writeln('--- LED ---');
      buffer.writeln('État: ${ledState.ledInfo.state ? 'ON' : 'OFF'}');
      buffer.writeln('Statut: ${ledState.ledInfo.status}');
      buffer.writeln();
    }

    if (deviceState is DeviceLoaded) {
      buffer.writeln('--- DEVICE ---');
      buffer.writeln('IP: ${deviceState.deviceInfo.ip}');
      buffer.writeln('SSID: ${deviceState.deviceInfo.ssid}');
      buffer.writeln('RSSI: ${deviceState.deviceInfo.rssi} dBm');
      buffer.writeln('Connecté: ${deviceState.deviceInfo.isConnected ? 'Oui' : 'Oui'}');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SelectableText(
        buffer.toString(),
        style: const TextStyle(
          fontFamily: 'Courier',
          fontSize: 12,
          height: 1.6,
        ),
      ),
    );
  }

  /// Vue Tableau
  Widget _buildTableView(
      SensorsState sensorsState,
      LedState ledState,
      DeviceState deviceState,
      ) {
    return Column(
      children: [
        if (sensorsState is SensorsLoaded && sensorsState.sensors.isNotEmpty) ...[
          _buildDataTable(
            'Capteurs',
            ['Nom', 'Valeur', 'Unité'],
            sensorsState.sensors
                .map((s) {
              try {
                return [
                  s.name,
                  s.value.toStringAsFixed(2),
                  s.unit,
                ];
              } catch (e) {
                return [s.name, 'N/A', s.unit];
              }
            })
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (ledState is LedLoaded)
          _buildDataTable(
            'LED',
            ['Propriété', 'Valeur'],
            [
              ['État', ledState.ledInfo.state ? 'ON' : 'OFF'],
              ['Statut', ledState.ledInfo.status.toString().split('.').last],
            ],
          ),
        if (deviceState is DeviceLoaded) ...[
          const SizedBox(height: 12),
          _buildDataTable(
            'Device',
            ['Propriété', 'Valeur'],
            [
              ['IP', deviceState.deviceInfo.ip],
              ['SSID', deviceState.deviceInfo.ssid],
              ['RSSI', '${deviceState.deviceInfo.rssi} dBm'],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSensorCard(
      String label,
      String value,
      String unit,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
      String label,
      String status,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
      String title,
      List<String> headers,
      List<List<String>> rows,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(
            color: Colors.grey[300]!,
            borderRadius: BorderRadius.circular(8),
          ),
          columnWidths: headers.length == 2
              ? const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
          }
              : null,
          children: [
            // Headers
            TableRow(
              decoration: BoxDecoration(
                color: Colors.grey[100],
              ),
              children: headers
                  .map((h) => Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  h,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ))
                  .toList(),
            ),
            // Rows
            ...rows.map(
                  (row) => TableRow(
                children: row
                    .map((cell) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    cell,
                    style: const TextStyle(fontSize: 12),
                  ),
                ))
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Card Historique Firestore avec export
  Widget _buildFirestoreHistoryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.cloud_queue, size: 24, color: Colors.orange),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Historique Firestore',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Cloud Storage',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: _loadFirestoreStats,
                  tooltip: 'Actualiser',
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Stats
            if (_isLoadingStats)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            else ...[
              _buildStatRow(
                'Enregistrements',
                _formatNumber(_totalRecords),
              ),
              _buildStatRow(
                'Taille données',
                '${_dataSize.toStringAsFixed(2)} MB',
              ),
              _buildStatRow(
                'Dernier sync',
                _lastSync != null ? _formatTimeSince(_lastSync!) : 'N/A',
                isLast: true,
              ),
            ],

            const SizedBox(height: 15),

            // Bouton Export avec menu déroulant
            _buildExportMenu(),
          ],
        ),
      ),
    );
  }

  /// Menu d'export avec choix de collection et format
  Widget _buildExportMenu() {
    return Column(
      children: [
        // Export Capteurs
        _buildExportButton(
          icon: Icons.sensors,
          label: 'Exporter Capteurs',
          color: Colors.blue,
          onPressed: () => _showExportDialog('sensors', 'Capteurs'),
        ),
        const SizedBox(height: 10),

        // Export LED
        _buildExportButton(
          icon: Icons.lightbulb,
          label: 'Exporter LED',
          color: Colors.amber,
          onPressed: () => _showExportDialog('led_status', 'LED'),
        ),
        const SizedBox(height: 10),

        // Export Device
        _buildExportButton(
          icon: Icons.devices,
          label: 'Exporter Device',
          color: Colors.purple,
          onPressed: () => _showExportDialog('device_info', 'Device'),
        ),
        const SizedBox(height: 10),

        // Export Tout
        _buildExportButton(
          icon: Icons.download,
          label: 'Exporter Tout',
          color: const Color(0xFF667eea),
          onPressed: () => _showExportDialog('all', 'Toutes les données'),
        ),
      ],
    );
  }

  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: color),
        ),
      ),
    );
  }

  /// Card Formats d'affichage
  Widget _buildDisplayFormatsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.view_list, size: 24, color: Colors.green),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Formats d\'affichage',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Format Buttons
            _buildFormatButton(
              '📊 Vue Dashboard',
              'Cartes visuelles avec icônes',
              DisplayFormat.dashboard,
            ),
            const SizedBox(height: 10),
            _buildFormatButton(
              '📋 Vue Tableau',
              'Données organisées en tableaux',
              DisplayFormat.table,
            ),
            const SizedBox(height: 10),
            _buildFormatButton(
              '📝 Vue Textuelle',
              'Format texte brut lisible',
              DisplayFormat.text,
            ),
            const SizedBox(height: 10),
            _buildFormatButton(
              '💾 Vue JSON',
              'Format JSON structuré',
              DisplayFormat.json,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isLast = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildFormatButton(String text, String subtitle, DisplayFormat format) {
    final isSelected = _selectedFormat == format;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          setState(() => _selectedFormat = format);
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(
            color: isSelected ? const Color(0xFF667eea) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          backgroundColor: isSelected ? const Color(0xFF667eea).withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF667eea) : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? const Color(0xFF667eea).withOpacity(0.7)
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF667eea),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // MÉTHODES D'EXPORT DE FICHIERS
  // ========================================================================

  /// Affiche le dialogue de sélection de format d'export
  void _showExportDialog(String collection, String collectionName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.download, color: Color(0xFF667eea)),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Exporter $collectionName'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choisissez le format d\'export :',
                style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 16),
            _buildExportFormatOption(
              '📄 JSON',
              'Format JSON standard',
                  () {
                Navigator.pop(context);
                _exportToJsonFile(collection, collectionName);
              },
            ),
            const SizedBox(height: 8),
            _buildExportFormatOption(
              '📊 CSV',
              'Format tableur Excel',
                  () {
                Navigator.pop(context);
                _exportToCsvFile(collection, collectionName);
              },
            ),
            const SizedBox(height: 8),
            _buildExportFormatOption(
              '📝 TXT',
              'Format texte lisible',
                  () {
                Navigator.pop(context);
                _exportToTxtFile(collection, collectionName);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportFormatOption(
      String title,
      String subtitle,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  /// Export vers JSON
  Future<void> _exportToJsonFile(String collection, String collectionName) async {
    try {
      _showLoadingDialog('Export JSON en cours...');

      List<Map<String, dynamic>> allData = [];

      if (collection == 'all') {
        // Exporter toutes les collections
        final sensors = await _firestore.collection('sensors').get();
        final led = await _firestore.collection('led_status').get();
        final device = await _firestore.collection('device_info').get();

        allData = [
          {
            'sensors': sensors.docs.map((doc) => doc.data()).toList(),
            'led_status': led.docs.map((doc) => doc.data()).toList(),
            'device_info': device.docs.map((doc) => doc.data()).toList(),
            'export_date': DateTime.now().toIso8601String(),
            'total_records': sensors.docs.length + led.docs.length + device.docs.length,
          }
        ];
      } else {
        // Exporter une seule collection
        final snapshot = await _firestore
            .collection(collection)
            .orderBy('timestamp', descending: true)
            .get();

        allData = snapshot.docs.map((doc) => doc.data()).toList();
      }

      // Créer le contenu JSON
      final jsonContent = const JsonEncoder.withIndent('  ').convert({
        'collection': collectionName,
        'export_date': DateTime.now().toIso8601String(),
        'count': collection == 'all' ? allData.first['total_records'] : allData.length,
        'data': collection == 'all' ? allData.first : allData,
      });

      // Créer le nom du fichier
      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final filename = 'export_${collection}_$timestamp.json';

      // Télécharger le fichier
      _downloadFile(jsonContent, filename, 'application/json');

      Navigator.pop(context); // Fermer le loading

      _showSuccessMessage('✅ Export JSON réussi!\nFichier: $filename');
    } catch (e) {
      Navigator.pop(context); // Fermer le loading
      _showErrorMessage('❌ Erreur export JSON: $e');
    }
  }

  /// Export vers CSV
  Future<void> _exportToCsvFile(String collection, String collectionName) async {
    try {
      _showLoadingDialog('Export CSV en cours...');

      final buffer = StringBuffer();

      if (collection == 'all') {
        // Export toutes collections
        buffer.writeln('=== EXPORT COMPLET ===\n');

        // Sensors
        buffer.writeln('CAPTEURS');
        final sensors = await _firestore.collection('sensors').get();
        buffer.writeln('Timestamp,Temperature,Light,Device ID');
        for (var doc in sensors.docs) {
          final data = doc.data();
          buffer.writeln('${data['timestamp'] ?? ''},${data['temperature'] ?? ''},${data['light'] ?? ''},${data['deviceId'] ?? ''}');
        }
        buffer.writeln();

        // LED
        buffer.writeln('LED STATUS');
        final led = await _firestore.collection('led_status').get();
        buffer.writeln('Timestamp,Status,State,Mode');
        for (var doc in led.docs) {
          final data = doc.data();
          buffer.writeln('${data['timestamp'] ?? ''},${data['status'] ?? ''},${data['state'] ?? ''},${data['mode'] ?? ''}');
        }
        buffer.writeln();

        // Device
        buffer.writeln('DEVICE INFO');
        final device = await _firestore.collection('device_info').get();
        buffer.writeln('Timestamp,IP,SSID,RSSI,Connected');
        for (var doc in device.docs) {
          final data = doc.data();
          buffer.writeln('${data['timestamp'] ?? ''},${data['ip'] ?? ''},${data['ssid'] ?? ''},${data['rssi'] ?? ''},${data['isConnected'] ?? ''}');
        }
      } else {
        // Export une collection
        final snapshot = await _firestore
            .collection(collection)
            .orderBy('timestamp', descending: true)
            .get();

        if (collection == 'sensors') {
          buffer.writeln('Timestamp,Temperature,Light,Device ID');
          for (var doc in snapshot.docs) {
            final data = doc.data();
            buffer.writeln('${data['timestamp'] ?? ''},${data['temperature'] ?? ''},${data['light'] ?? ''},${data['deviceId'] ?? ''}');
          }
        } else if (collection == 'led_status') {
          buffer.writeln('Timestamp,Status,State,Mode');
          for (var doc in snapshot.docs) {
            final data = doc.data();
            buffer.writeln('${data['timestamp'] ?? ''},${data['status'] ?? ''},${data['state'] ?? ''},${data['mode'] ?? ''}');
          }
        } else if (collection == 'device_info') {
          buffer.writeln('Timestamp,IP,SSID,RSSI,Connected');
          for (var doc in snapshot.docs) {
            final data = doc.data();
            buffer.writeln('${data['timestamp'] ?? ''},${data['ip'] ?? ''},${data['ssid'] ?? ''},${data['rssi'] ?? ''},${data['isConnected'] ?? ''}');
          }
        }
      }

      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final filename = 'export_${collection}_$timestamp.csv';

      _downloadFile(buffer.toString(), filename, 'text/csv');

      Navigator.pop(context);
      _showSuccessMessage('✅ Export CSV réussi!\nFichier: $filename');
    } catch (e) {
      Navigator.pop(context);
      _showErrorMessage('❌ Erreur export CSV: $e');
    }
  }

  /// Export vers TXT
  Future<void> _exportToTxtFile(String collection, String collectionName) async {
    try {
      _showLoadingDialog('Export TXT en cours...');

      final buffer = StringBuffer();
      buffer.writeln('=================================');
      buffer.writeln('EXPORT IoT ESP32 - $collectionName');
      buffer.writeln('=================================');
      buffer.writeln('Date: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now())}');
      buffer.writeln('=================================\n');

      if (collection == 'all') {
        // Export tout
        final sensors = await _firestore.collection('sensors').get();
        final led = await _firestore.collection('led_status').get();
        final device = await _firestore.collection('device_info').get();

        buffer.writeln('--- CAPTEURS (${sensors.docs.length} enregistrements) ---\n');
        for (var doc in sensors.docs.take(50)) {
          final data = doc.data();
          final timestamp = data['timestamp'];
          final date = timestamp != null
              ? DateFormat('dd/MM/yyyy HH:mm:ss').format(
              DateTime.fromMillisecondsSinceEpoch(
                  timestamp is int ? timestamp : int.parse(timestamp.toString())
              )
          )
              : 'N/A';
          buffer.writeln('📅 $date');
          buffer.writeln('  🌡️ Température: ${data['temperature'] ?? 'N/A'}°C');
          buffer.writeln('  💡 Lumière: ${data['light'] ?? 'N/A'} lux');
          buffer.writeln('  📱 Device: ${data['deviceId'] ?? 'N/A'}');
          buffer.writeln();
        }

        buffer.writeln('--- LED STATUS (${led.docs.length} enregistrements) ---\n');
        for (var doc in led.docs.take(50)) {
          final data = doc.data();
          final timestamp = data['timestamp'];
          final date = timestamp != null
              ? DateFormat('dd/MM/yyyy HH:mm:ss').format(
              DateTime.fromMillisecondsSinceEpoch(
                  timestamp is int ? timestamp : int.parse(timestamp.toString())
              )
          )
              : 'N/A';
          buffer.writeln('📅 $date');
          buffer.writeln('  💡 Status: ${data['status'] ?? 'N/A'}');
          buffer.writeln('  🔘 State: ${data['state'] ?? 'N/A'}');
          buffer.writeln('  ⚙️ Mode: ${data['mode'] ?? 'N/A'}');
          buffer.writeln();
        }

        buffer.writeln('--- DEVICE INFO (${device.docs.length} enregistrements) ---\n');
        for (var doc in device.docs.take(50)) {
          final data = doc.data();
          final timestamp = data['timestamp'];
          final date = timestamp != null
              ? DateFormat('dd/MM/yyyy HH:mm:ss').format(
              DateTime.fromMillisecondsSinceEpoch(
                  timestamp is int ? timestamp : int.parse(timestamp.toString())
              )
          )
              : 'N/A';
          buffer.writeln('📅 $date');
          buffer.writeln('  🌐 IP: ${data['ip'] ?? 'N/A'}');
          buffer.writeln('  📡 SSID: ${data['ssid'] ?? 'N/A'}');
          buffer.writeln('  📶 RSSI: ${data['rssi'] ?? 'N/A'} dBm');
          buffer.writeln('  ✅ Connected: ${data['isConnected'] ?? 'N/A'}');
          buffer.writeln();
        }
      } else {
        // Export une collection
        final snapshot = await _firestore
            .collection(collection)
            .orderBy('timestamp', descending: true)
            .limit(100)
            .get();

        buffer.writeln('Total: ${snapshot.docs.length} enregistrements\n');

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final timestamp = data['timestamp'];
          final date = timestamp != null
              ? DateFormat('dd/MM/yyyy HH:mm:ss').format(
              DateTime.fromMillisecondsSinceEpoch(
                  timestamp is int ? timestamp : int.parse(timestamp.toString())
              )
          )
              : 'N/A';

          buffer.writeln('📅 $date');

          if (collection == 'sensors') {
            buffer.writeln('  🌡️ Température: ${data['temperature'] ?? 'N/A'}°C');
            buffer.writeln('  💡 Lumière: ${data['light'] ?? 'N/A'} lux');
            buffer.writeln('  📱 Device: ${data['deviceId'] ?? 'N/A'}');
          } else if (collection == 'led_status') {
            buffer.writeln('  💡 Status: ${data['status'] ?? 'N/A'}');
            buffer.writeln('  🔘 State: ${data['state'] ?? 'N/A'}');
            buffer.writeln('  ⚙️ Mode: ${data['mode'] ?? 'N/A'}');
          } else if (collection == 'device_info') {
            buffer.writeln('  🌐 IP: ${data['ip'] ?? 'N/A'}');
            buffer.writeln('  📡 SSID: ${data['ssid'] ?? 'N/A'}');
            buffer.writeln('  📶 RSSI: ${data['rssi'] ?? 'N/A'} dBm');
            buffer.writeln('  ✅ Connected: ${data['isConnected'] ?? 'N/A'}');
          }
          buffer.writeln();
        }
      }

      buffer.writeln('=================================');
      buffer.writeln('Fin de l\'export');
      buffer.writeln('=================================');

      final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final filename = 'export_${collection}_$timestamp.txt';

      _downloadFile(buffer.toString(), filename, 'text/plain');

      Navigator.pop(context);
      _showSuccessMessage('✅ Export TXT réussi!\nFichier: $filename');
    } catch (e) {
      Navigator.pop(context);
      _showErrorMessage('❌ Erreur export TXT: $e');
    }
  }

  /// Télécharge un fichier (fonctionne sur Flutter Web)
  void _downloadFile(String content, String filename, String mimeType) {
    // Convertir le contenu en bytes
    final bytes = Uint8List.fromList(utf8.encode(content));

    // Créer un blob
    final blob = html.Blob([bytes], mimeType);

    // Créer une URL pour le blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Créer un lien de téléchargement
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();

    // Nettoyer
    html.Url.revokeObjectUrl(url);
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ========================================================================
  // MÉTHODES UTILITAIRES
  // ========================================================================

  String _getFormatLabel() {
    switch (_selectedFormat) {
      case DisplayFormat.json:
        return 'Format JSON';
      case DisplayFormat.dashboard:
        return 'Format Dashboard';
      case DisplayFormat.text:
        return 'Format Texte';
      case DisplayFormat.table:
        return 'Format Tableau';
    }
  }

  Map<String, dynamic> _buildJsonData(
      SensorsState sensorsState,
      LedState ledState,
      DeviceState deviceState,
      ) {
    final data = <String, dynamic>{
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'source': 'ESP32',
      'device': {},
      'sensors': [],
      'led': {},
    };

    if (deviceState is DeviceLoaded) {
      data['device'] = {
        'ip': deviceState.deviceInfo.ip,
        'ssid': deviceState.deviceInfo.ssid,
        'rssi': deviceState.deviceInfo.rssi,
        'connected': deviceState.deviceInfo.isConnected,
      };
    }

    if (sensorsState is SensorsLoaded) {
      data['sensors'] = sensorsState.sensors.map((s) {
        try {
          return {
            'id': s.id,
            'name': s.name,
            'type': s.type,
            'value': double.parse(s.value.toStringAsFixed(2)),
            'unit': s.unit,
          };
        } catch (e) {
          return {
            'id': s.id,
            'name': s.name,
            'type': s.type,
            'value': 0.0,
            'unit': s.unit,
          };
        }
      }).toList();
    }

    if (ledState is LedLoaded) {
      data['led'] = {
        'status': ledState.ledInfo.status.toString().split('.').last,
        'state': ledState.ledInfo.state,
      };
    }

    return data;
  }

  String _formatJson(Map<String, dynamic> json) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(json);
  }

  String _formatNumber(int number) {
    try {
      final formatter = NumberFormat('#,###', 'fr_FR');
      return formatter.format(number);
    } catch (e) {
      return number.toString();
    }
  }

  String _formatTimeSince(DateTime date) {
    try {
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inSeconds < 60) {
        return 'Il y a ${difference.inSeconds}s';
      } else if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes}min';
      } else if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours}h';
      } else {
        return 'Il y a ${difference.inDays}j';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  void _copyToClipboard() {
    try {
      final sensorsState = context.read<SensorsBloc>().state;
      final ledState = context.read<LedBloc>().state;
      final deviceState = context.read<DeviceBloc>().state;

      final jsonData = _buildJsonData(sensorsState, ledState, deviceState);
      final jsonString = _formatJson(jsonData);

      Clipboard.setData(ClipboardData(text: jsonString));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ JSON copié dans le presse-papiers'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur copie: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}