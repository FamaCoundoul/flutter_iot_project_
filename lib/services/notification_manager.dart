import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestionnaire centralisé des notifications Firebase Cloud Messaging
/// Adapté pour Flutter Web (sans subscribeToTopic)
class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isInitialized = false;
  String? _currentToken;

  // Clé VAPID pour Flutter Web
  static const String _vapidKey = 'BI2k-RWDMuN80-GnvjuXjGPjPSf7NxH6L8hJ-0cwlzJ6rR9FTwVWjmOw3l3avEVQvWA5LL8toLrfiRdmKG-9AnI';

  /// Initialise Firebase Messaging (à appeler dans main.dart)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Écouter les messages en premier plan
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Écouter les clics sur les notifications
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

      // Vérifier si l'app a été ouverte depuis une notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage);
      }

      _isInitialized = true;
      debugPrint('✅ NotificationManager initialisé');
    } catch (e) {
      debugPrint('❌ Erreur initialisation NotificationManager: $e');
    }
  }

  /// Demande la permission et obtient le token FCM
  Future<String?> requestPermissionAndGetToken() async {
    try {
      // 1. Demander la permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('❌ Permission notifications refusée');
        return null;
      }

      debugPrint('✅ Permission notifications accordée');

      // 2. Obtenir le token (avec VAPID pour Web)
      final token = await _messaging.getToken(
        vapidKey: _vapidKey,
      );

      if (token != null) {
        debugPrint('✅ Token FCM obtenu: ${token.substring(0, 20)}...');
        _currentToken = token;

        // Sauvegarder le token
        await _saveToken(token);
      }

      return token;
    } catch (e) {
      debugPrint('❌ Erreur obtention token: $e');
      return null;
    }
  }

  /// Sauvegarde le token dans Firestore et SharedPreferences
  /// Sur Web, on sauvegarde le token avec les topics souhaités
  Future<void> _saveToken(String token) async {
    try {
      // Sauvegarder dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);

      // Sur Web, sauvegarder le token avec les topics dans Firestore
      // Le backend utilisera cette info pour envoyer aux bons tokens
      await _firestore.collection('fcm_tokens').doc(token).set({
        'token': token,
        'platform': kIsWeb ? 'web' : 'mobile',
        'deviceId': 'esp32_device',
        'topics': ['device_esp32', 'all_devices'], // Topics pour ce token
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint('✅ Token sauvegardé: Firestore + SharedPreferences');
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde token: $e');
    }
  }

  /// Ajoute un topic pour ce token (Web compatible)
  /// Sur Web, on met à jour Firestore au lieu d'utiliser subscribeToTopic
  Future<void> addTopic(String topic) async {
    try {
      if (_currentToken == null) {
        debugPrint('⚠️ Pas de token FCM disponible');
        return;
      }

      if (kIsWeb) {
        // Sur Web, mettre à jour Firestore
        await _firestore.collection('fcm_tokens').doc(_currentToken).update({
          'topics': FieldValue.arrayUnion([topic]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ Topic ajouté dans Firestore (Web): $topic');
      } else {
        // Sur Mobile, utiliser l'API native
        await _messaging.subscribeToTopic(topic);
        debugPrint('✅ Abonné au topic (Mobile): $topic');
      }
    } catch (e) {
      debugPrint('❌ Erreur ajout topic: $e');
    }
  }

  /// Retire un topic pour ce token (Web compatible)
  Future<void> removeTopic(String topic) async {
    try {
      if (_currentToken == null) {
        debugPrint('⚠️ Pas de token FCM disponible');
        return;
      }

      if (kIsWeb) {
        // Sur Web, mettre à jour Firestore
        await _firestore.collection('fcm_tokens').doc(_currentToken).update({
          'topics': FieldValue.arrayRemove([topic]),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ Topic retiré de Firestore (Web): $topic');
      } else {
        // Sur Mobile, utiliser l'API native
        await _messaging.unsubscribeFromTopic(topic);
        debugPrint('✅ Désabonné du topic (Mobile): $topic');
      }
    } catch (e) {
      debugPrint('❌ Erreur retrait topic: $e');
    }
  }

  /// Gestion des messages reçus en premier plan
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📨 Message reçu (foreground):');
    debugPrint('  Title: ${message.notification?.title}');
    debugPrint('  Body: ${message.notification?.body}');
    debugPrint('  Data: ${message.data}');
  }

  /// Gestion des clics sur les notifications
  void _handleNotificationClick(RemoteMessage message) {
    debugPrint('📬 Notification cliquée:');
    debugPrint('  Data: ${message.data}');

    final type = message.data['type'];
    switch (type) {
      case 'threshold_alert':
        debugPrint('  → Type: Alerte de seuil');
        break;
      case 'connection_lost':
        debugPrint('  → Type: Connexion perdue');
        break;
      default:
        debugPrint('  → Type: Autre notification');
    }
  }

  /// Sauvegarde l'état des notifications
  Future<void> saveNotificationState(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
      debugPrint('✅ État notifications sauvegardé: $enabled');
    } catch (e) {
      debugPrint('❌ Erreur sauvegarde état: $e');
    }
  }

  /// Charge l'état des notifications
  Future<bool> loadNotificationState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notifications_enabled') ?? false;
      debugPrint('✅ État notifications chargé: $enabled');
      return enabled;
    } catch (e) {
      debugPrint('❌ Erreur chargement état: $e');
      return false;
    }
  }

  /// Récupère le token actuel
  String? get currentToken => _currentToken;

  /// Charge le token depuis SharedPreferences
  Future<String?> loadSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');
      _currentToken = token;
      return token;
    } catch (e) {
      debugPrint('❌ Erreur chargement token: $e');
      return null;
    }
  }

  /// Envoie une notification de test (nécessite un backend)
  Future<void> sendTestNotification() async {
    try {
      if (_currentToken == null) {
        debugPrint('⚠️ Pas de token disponible');
        return;
      }

      // Créer une demande de notification dans Firestore
      // Le backend lira cette collection et enverra la notification
      await _firestore.collection('test_notifications').add({
        'token': _currentToken,
        'title': '🧪 Test Notification',
        'body': 'Ceci est une notification de test',
        'data': {
          'type': 'test',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint('📤 Demande de notification de test créée dans Firestore');
    } catch (e) {
      debugPrint('❌ Erreur envoi test: $e');
    }
  }
}

/// Widget pour tester les notifications
class NotificationTestButton extends StatelessWidget {
  const NotificationTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _testNotification(context),
      icon: const Icon(Icons.notification_add),
      label: const Text('Tester les notifications'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }

  Future<void> _testNotification(BuildContext context) async {
    try {
      final manager = NotificationManager();

      // Demander la permission et obtenir le token
      final token = await manager.requestPermissionAndGetToken();

      if (token != null) {
        // Ajouter le topic (Web compatible)
        await manager.addTopic('device_esp32');

        // Sauvegarder l'état
        await manager.saveNotificationState(true);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✅ Notifications activées !',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Token FCM:', style: TextStyle(fontSize: 11)),
                  Text(
                    token.length > 50 ? '${token.substring(0, 50)}...' : token,
                    style: const TextStyle(fontSize: 9, fontFamily: 'Courier'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kIsWeb
                        ? 'Topics sauvegardés dans Firestore'
                        : 'Topic: device_esp32',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 6),
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Impossible d\'obtenir le token FCM'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}