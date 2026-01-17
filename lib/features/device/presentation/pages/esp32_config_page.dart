import 'package:flutter/material.dart';
import '../../../../app/di.dart';
import '../../../../core/network/esp32_config_service.dart';
import '../../../../core/network/esp32_http_client.dart';

/// Page de configuration de l'ESP32
class ESP32ConfigPage extends StatefulWidget {
  const ESP32ConfigPage({super.key});

  @override
  State<ESP32ConfigPage> createState() => _ESP32ConfigPageState();
}

class _ESP32ConfigPageState extends State<ESP32ConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();

  bool _isLoading = false;
  bool _isTesting = false;
  String? _errorMessage;
  String? _successMessage;
  ConnectionStatus _connectionStatus = ConnectionStatus.unknown;

  @override
  void initState() {
    super.initState();
    _loadCurrentUrl();
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _loadCurrentUrl() {
    final configService = getIt<ESP32ConfigService>();
    _urlController.text = configService.getBaseUrl();
  }

  Future<void> _testConnection() async {
    // Validation légère avant test
    final raw = _urlController.text.trim();
    final formatted = ESP32ConfigService.formatUrl(raw);

    if (!ESP32ConfigService.isValidUrl(formatted)) {
      setState(() {
        _connectionStatus = ConnectionStatus.failed;
        _errorMessage = 'Format d\'URL invalide';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _errorMessage = null;
      _successMessage = null;
      _connectionStatus = ConnectionStatus.testing;
    });

    try {
      final currentConfig = getIt<ESP32ConfigService>();
      final oldUrl = currentConfig.getBaseUrl();

      // On remplace temporairement l'URL juste pour le test
      await currentConfig.saveBaseUrl(formatted);

      // On utilise le client du DI (il lit l'URL dynamiquement à chaque requête)
      final client = getIt<ESP32HttpClient>();
      final isConnected = await client.testConnection();

      // On restaure l'ancienne URL (pour ne pas impacter l'app tant que l'utilisateur n'a pas sauvegardé)
      await currentConfig.saveBaseUrl(oldUrl);

      setState(() {
        _isTesting = false;
        if (isConnected) {
          _connectionStatus = ConnectionStatus.connected;
          _successMessage = 'Connexion réussie à l\'ESP32 !';
        } else {
          _connectionStatus = ConnectionStatus.failed;
          _errorMessage = 'Impossible de se connecter à l\'ESP32';
        }
      });
    } catch (e) {
      setState(() {
        _isTesting = false;
        _connectionStatus = ConnectionStatus.failed;
        _errorMessage = 'Erreur: $e';
      });
    }
  }

  Future<void> _saveConfiguration() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final url = ESP32ConfigService.formatUrl(_urlController.text.trim());

      // ✅ Un seul endroit : on met à jour la config (pas de ré-enregistrement client)
      await updateESP32Url(url);

      setState(() {
        _isLoading = false;
        _successMessage = 'Configuration sauvegardée !';
        _connectionStatus = ConnectionStatus.unknown; // optionnel : reset statut
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erreur lors de la sauvegarde: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration ESP32'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.settings_input_antenna,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Connexion ESP32',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Configurez l\'adresse IP de votre ESP32',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'Adresse IP de l\'ESP32',
                  hintText: 'http://192.168.1.20 ou 192.168.1.20',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                  helperText: 'Format: http://IP ou juste l\'IP',
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une adresse IP';
                  }
                  final formatted = ESP32ConfigService.formatUrl(value.trim());
                  if (!ESP32ConfigService.isValidUrl(formatted)) {
                    return 'Format d\'URL invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _ConnectionStatusCard(
                status: _connectionStatus,
                isTesting: _isTesting,
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.wifi_find),
                label: Text(_isTesting ? 'Test en cours...' : 'Tester la connexion'),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              FilledButton.icon(
                onPressed: _isLoading ? null : _saveConfiguration,
                icon: _isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Sauvegarde...' : 'Sauvegarder'),
              ),
              const SizedBox(height: 16),

              _buildInstructions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Comment trouver l\'IP ?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInstructionStep('1', 'Regardez l\'écran TTGO de l\'ESP32'),
          _buildInstructionStep('2', 'L\'IP s\'affiche après "WiFi: OK"'),
          _buildInstructionStep('3', 'Ou utilisez le moniteur série (115200 baud)'),
          const SizedBox(height: 8),
          Text(
            'Exemple: 192.168.1.20',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}

enum ConnectionStatus {
  unknown,
  testing,
  connected,
  failed,
}

class _ConnectionStatusCard extends StatelessWidget {
  final ConnectionStatus status;
  final bool isTesting;

  const _ConnectionStatusCard({
    required this.status,
    required this.isTesting,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color iconColor;
    IconData icon;
    String text;

    switch (status) {
      case ConnectionStatus.unknown:
        backgroundColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade300;
        iconColor = Colors.grey.shade600;
        icon = Icons.help_outline;
        text = 'Connexion non testée';
        break;
      case ConnectionStatus.testing:
        backgroundColor = Colors.blue.shade50;
        borderColor = Colors.blue.shade200;
        iconColor = Colors.blue.shade700;
        icon = Icons.sync;
        text = 'Test de connexion en cours...';
        break;
      case ConnectionStatus.connected:
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green.shade200;
        iconColor = Colors.green.shade700;
        icon = Icons.check_circle;
        text = 'ESP32 connecté';
        break;
      case ConnectionStatus.failed:
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red.shade200;
        iconColor = Colors.red.shade700;
        icon = Icons.error;
        text = 'Échec de connexion';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          if (isTesting)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: iconColor,
              ),
            )
          else
            Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: iconColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
