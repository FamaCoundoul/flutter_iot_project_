// Service Worker pour Firebase Cloud Messaging
// IMPORTANT: Ce fichier doit etre a la racine de web/

importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Configuration Firebase - flutter-iot-project-11d02
firebase.initializeApp({
  apiKey: "AIzaSyB-a6aGYCQpW5krLHh5OMiUN-arkVPKVOQ",
  authDomain: "flutter-iot-project-11d02.firebaseapp.com",
  projectId: "flutter-iot-project-11d02",
  storageBucket: "flutter-iot-project-11d02.firebasestorage.app",
  messagingSenderId: "105800259177",
  appId: "1:105800259177:android:5195ee2032a610884974f8"
});

const messaging = firebase.messaging();

// GESTION DES REQUETES RESEAU - IMPORTANT POUR FLUTTER WEB
const BYPASS_DOMAINS = [
  'fonts.googleapis.com',
  'fonts.gstatic.com',
  'www.gstatic.com',
  'firebasestorage.googleapis.com',
  'firebase.googleapis.com',
  'fcm.googleapis.com',
  'firebaseinstallations.googleapis.com',
];

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  const shouldBypass = BYPASS_DOMAINS.some(domain => url.hostname.includes(domain)) ||
                       url.pathname.includes('flutter') ||
                       url.pathname.includes('main.dart.js') ||
                       url.pathname.includes('canvaskit');

  if (shouldBypass) {
    return;
  }

  event.respondWith(fetch(event.request));
});

// GESTION DES NOTIFICATIONS EN ARRIERE-PLAN
messaging.onBackgroundMessage((payload) => {
  console.log('[FCM] Message recu en arriere-plan:', payload);

  const notificationTitle = payload.notification?.title || 'IoT ESP32 Alert';
  const notificationOptions = {
    body: payload.notification?.body || 'Nouvelle alerte de votre device',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: payload.data?.type || 'iot-notification',
    requireInteraction: true,
    data: payload.data,
    vibrate: [200, 100, 200],
    actions: [
      {
        action: 'view',
        title: 'Voir'
      },
      {
        action: 'dismiss',
        title: 'Ignorer'
      }
    ]
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// GESTION DES CLICS SUR LES NOTIFICATIONS
self.addEventListener('notificationclick', (event) => {
  console.log('[FCM] Notification cliquee:', event);

  event.notification.close();

  if (event.action === 'view') {
    event.waitUntil(
      clients.matchAll({ type: 'window', includeUncontrolled: true })
        .then((clientList) => {
          for (const client of clientList) {
            if (client.url.includes(self.location.origin) && 'focus' in client) {
              return client.focus();
            }
          }
          if (clients.openWindow) {
            return clients.openWindow('/');
          }
        })
    );
  }
});

// EVENEMENTS DU SERVICE WORKER
self.addEventListener('install', (event) => {
  console.log('[FCM] Service Worker installe');
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  console.log('[FCM] Service Worker active');
  event.waitUntil(clients.claim());
});

console.log('[FCM] Service Worker Firebase Messaging charge - flutter-iot-project-11d02');