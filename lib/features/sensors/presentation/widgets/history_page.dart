import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Filtres
  String _selectedCollection = 'sensors';
  DateTime? _startDate;
  DateTime? _endDate;
  final TextEditingController _searchController = TextEditingController();

  // Pagination
  final int _itemsPerPage = 20;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Données'),
        backgroundColor: const Color(0xFF667eea),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtres',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et sélection collection
          _buildTopBar(),

          // Filtres actifs
          if (_startDate != null || _endDate != null)
            _buildActiveFilters(),

          // Liste des données
          Expanded(
            child: _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Sélecteur de collection
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _selectedCollection,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF667eea)),
              style: const TextStyle(
                color: Color(0xFF667eea),
                fontWeight: FontWeight.w600,
              ),
              items: const [
                DropdownMenuItem(
                  value: 'sensors',
                  child: Row(
                    children: [
                      Icon(Icons.sensors, size: 20, color: Color(0xFF667eea)),
                      SizedBox(width: 8),
                      Text('Données Capteurs'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'led_status',
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, size: 20, color: Color(0xFF667eea)),
                      SizedBox(width: 8),
                      Text('Historique LED'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'device_info',
                  child: Row(
                    children: [
                      Icon(Icons.devices, size: 20, color: Color(0xFF667eea)),
                      SizedBox(width: 8),
                      Text('Infos Device'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCollection = value;
                    _lastDocument = null;
                    _hasMore = true;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.amber[50],
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 20, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Filtres actifs : ${_formatDateRange()}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    Query query = _firestore
        .collection(_selectedCollection)
        .orderBy('timestamp', descending: true);

    // Appliquer les filtres de date
    if (_startDate != null) {
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: _startDate!.millisecondsSinceEpoch,
      );
    }
    if (_endDate != null) {
      query = query.where(
        'timestamp',
        isLessThanOrEqualTo: _endDate!.millisecondsSinceEpoch,
      );
    }

    query = query.limit(_itemsPerPage);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erreur: ${snapshot.error}'),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Aucune donnée disponible',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return _buildHistoryItem(data, index);
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> data, int index) {
    final timestamp = data['timestamp'] as int?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: _getCollectionColor().withOpacity(0.2),
            child: Icon(
              _getCollectionIcon(),
              color: _getCollectionColor(),
              size: 20,
            ),
          ),
          title: Text(
            _getCollectionTitle(),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            timestamp != null
                ? _formatTimestamp(timestamp)
                : 'Aucun timestamp',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          trailing: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.grey[600],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Affichage spécifique selon la collection
                  if (_selectedCollection == 'sensors')
                    _buildSensorData(data)
                  else if (_selectedCollection == 'led_status')
                    _buildLedData(data)
                  else if (_selectedCollection == 'device_info')
                      _buildDeviceData(data),

                  const Divider(height: 24),

                  // JSON complet
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282c34),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      const JsonEncoder.withIndent('  ').convert(data),
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 11,
                        color: Color(0xFFabb2bf),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorData(Map<String, dynamic> data) {
    final temperature = data['temperature'];
    final light = data['light'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Valeurs Capteurs',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        if (temperature != null)
          _buildDataRow(
            Icons.thermostat,
            'Température',
            '${temperature.toStringAsFixed(1)}°C',
            Colors.red,
          ),
        if (light != null)
          _buildDataRow(
            Icons.light_mode,
            'Lumière',
            '$light lux',
            Colors.amber,
          ),
      ],
    );
  }

  Widget _buildLedData(Map<String, dynamic> data) {
    final status = data['status'];
    final state = data['state'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'État LED',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        _buildDataRow(
          Icons.lightbulb,
          'Statut',
          status?.toString() ?? 'N/A',
          state == true ? Colors.green : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildDeviceData(Map<String, dynamic> data) {
    final ip = data['ip'];
    final ssid = data['ssid'];
    final rssi = data['rssi'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations Device',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        if (ip != null)
          _buildDataRow(Icons.wifi, 'IP', ip, Colors.blue),
        if (ssid != null)
          _buildDataRow(Icons.router, 'SSID', ssid, Colors.blue),
        if (rssi != null)
          _buildDataRow(Icons.signal_cellular_alt, 'RSSI', '$rssi dBm', Colors.blue),
      ],
    );
  }

  Widget _buildDataRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.filter_alt, color: Color(0xFF667eea)),
            SizedBox(width: 12),
            Text('Filtrer par Date'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date de début'),
              subtitle: Text(
                _startDate != null
                    ? DateFormat('dd/MM/yyyy').format(_startDate!)
                    : 'Non définie',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                  Navigator.pop(context);
                  _showFilterDialog();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date de fin'),
              subtitle: Text(
                _endDate != null
                    ? DateFormat('dd/MM/yyyy').format(_endDate!)
                    : 'Non définie',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate ?? DateTime.now(),
                  firstDate: _startDate ?? DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                  Navigator.pop(context);
                  _showFilterDialog();
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _startDate = null;
                _endDate = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Réinitialiser'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
            ),
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }

  Color _getCollectionColor() {
    switch (_selectedCollection) {
      case 'sensors':
        return Colors.blue;
      case 'led_status':
        return Colors.amber;
      case 'device_info':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCollectionIcon() {
    switch (_selectedCollection) {
      case 'sensors':
        return Icons.sensors;
      case 'led_status':
        return Icons.lightbulb;
      case 'device_info':
        return Icons.devices;
      default:
        return Icons.data_object;
    }
  }

  String _getCollectionTitle() {
    switch (_selectedCollection) {
      case 'sensors':
        return 'Capteurs';
      case 'led_status':
        return 'LED';
      case 'device_info':
        return 'Device';
      default:
        return 'Donnée';
    }
  }

  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  String _formatDateRange() {
    if (_startDate != null && _endDate != null) {
      return '${DateFormat('dd/MM/yy').format(_startDate!)} - ${DateFormat('dd/MM/yy').format(_endDate!)}';
    } else if (_startDate != null) {
      return 'Depuis ${DateFormat('dd/MM/yy').format(_startDate!)}';
    } else if (_endDate != null) {
      return 'Jusqu\'au ${DateFormat('dd/MM/yy').format(_endDate!)}';
    }
    return '';
  }
}