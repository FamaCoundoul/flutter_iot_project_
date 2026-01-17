import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_iot_project/core/constants/firestore_constants.dart';

class IoTFirebaseService {
  final FirebaseFirestore _db;
  final FirebaseMessaging _messaging;

  IoTFirebaseService({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  // ---------------------------------------------------------------------------
  // SETTINGS (current + history)
  // ---------------------------------------------------------------------------
  Future<void> saveDeviceSettingsWithHistory({
    required String deviceId,
    required Map<String, dynamic> data,
  }) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final currentRef = _db.doc(FirestorePaths.settingsDoc(deviceId));
    final historyRef = currentRef.collection('history').doc();

    final payload = {
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
      'clientUpdatedAtMs': nowMs,
      'platform': kIsWeb ? 'web' : 'mobile',
    };

    final batch = _db.batch();
    batch.set(currentRef, payload, SetOptions(merge: true));
    batch.set(historyRef, payload);
    await batch.commit();
  }

  /// Récupère la configuration courante du device
  Future<Map<String, dynamic>> getDeviceSettings(String deviceId) async {
    final docRef = _db.doc(FirestorePaths.settingsDoc(deviceId));
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      return {};
    }

    return snapshot.data() ?? {};
  }

  // ---------------------------------------------------------------------------
  // NOTIFICATIONS (FCM) - SUPPORT WEB COMPLET
  // ---------------------------------------------------------------------------

  /// Active les notifications (Web + Mobile)
  Future<void> enableNotifications(String deviceId) async {
    try {
      // 1. Demander la permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        throw Exception('Permission notifications refusée par l\'utilisateur');
      }

      // 2. Obtenir le token
      String? token;

      if (kIsWeb) {
        // Sur Web, utiliser VAPID key
        token = await _messaging.getToken(
          vapidKey: 'VOTRE_VAPID_KEY_ICI', // ← À REMPLACER
        );
      } else {
        // Sur Mobile, token classique
        token = await _messaging.getToken();
      }

      if (token == null) {
        throw Exception('Impossible de récupérer le token FCM');
      }

      debugPrint('✅ Token FCM obtenu: ${token.substring(0, 20)}...');

      // 3. Sauvegarder le token dans Firestore
      await _saveToken(token, deviceId);

      // 4. S'abonner au topic du device
      await _messaging.subscribeToTopic('device_$deviceId');

      debugPrint('✅ Abonné au topic: device_$deviceId');

    } catch (e) {
      debugPrint('❌ Erreur activation notifications: $e');
      rethrow;
    }
  }

  /// Désactive les notifications
  Future<void> disableNotifications(String deviceId) async {
    try {
      await _messaging.unsubscribeFromTopic('device_$deviceId');
      debugPrint('✅ Désabonné du topic: device_$deviceId');
    } catch (e) {
      debugPrint('❌ Erreur désactivation notifications: $e');
    }
  }

  /// Sauvegarde le token FCM dans Firestore
  Future<void> _saveToken(String token, String deviceId) async {
    final platform = kIsWeb ? 'web' : 'mobile';

    await _db.doc(FirestorePaths.tokenDoc(token)).set({
      'token': token,
      'deviceId': deviceId,
      'platform': platform,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('✅ Token sauvegardé dans Firestore');
  }

  /// Écoute les messages en premier plan (foreground)
  void listenToForegroundMessages({
    required Function(RemoteMessage) onMessage,
  }) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📨 Message reçu (foreground): ${message.notification?.title}');
      onMessage(message);
    });
  }

  /// Écoute les clics sur les notifications
  void listenToNotificationClicks({
    required Function(RemoteMessage) onMessageOpenedApp,
  }) {
    // App ouverte depuis une notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 Notification cliquée: ${message.data}');
      onMessageOpenedApp(message);
    });

    // Vérifier si l'app a été ouverte depuis une notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('📭 App ouverte depuis notification: ${message.data}');
        onMessageOpenedApp(message);
      }
    });
  }

  /// Envoie une notification de test
  Future<void> sendTestNotification(String deviceId) async {
    // Cette fonction nécessite un backend (Cloud Functions)
    // Pour tester, utilisez la console Firebase ou un backend
    await _db.collection('test_notifications').add({
      'deviceId': deviceId,
      'title': 'Test Notification',
      'body': 'Ceci est un test de notification',
      'timestamp': FieldValue.serverTimestamp(),
    });

    debugPrint('📤 Demande de notification de test envoyée');
  }
}