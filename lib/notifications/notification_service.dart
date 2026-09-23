import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logger.dart';

/// Top-level handler for background messages (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'freshveg_orders';
  static const _channelName = 'Order Updates';
  static const _channelDesc = 'Notifications for order status changes';

  /// Call once from main() before runApp
  Future<void> initialize() async {
    // Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    AppLogger.info('FCM permission: ${settings.authorizationStatus}');

    // Android notification channel
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Init local notifications
    const androidInit = AndroidInitializationSettings('ic_notification');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Foreground message display
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle initial message (app launched from notification)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    AppLogger.info('NotificationService initialized');
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.info('Foreground FCM: ${message.notification?.title}');
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notification',
          color: Color(0xFF2E7D32),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.info('Notification tapped: ${message.data}');
    // Navigation would be handled here via a global navigator key
    // e.g. navigatorKey.currentState?.pushNamed('/order/${message.data['orderId']}')
  }

  void _onNotificationTap(NotificationResponse response) {
    AppLogger.info('Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      AppLogger.info('Payload data: $data');
    }
  }

  /// Save FCM token to Firestore for the given user
  Future<void> saveTokenForUser(String uid) async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fcmToken': token,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        AppLogger.info('FCM token saved for user: $uid');
      }
      // Refresh token listener
      _fcm.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fcmToken': newToken,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      AppLogger.error('Error saving FCM token: $e');
    }
  }

  /// Remove FCM token on logout
  Future<void> removeTokenForUser(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': FieldValue.delete(),
      });
      await _fcm.deleteToken();
    } catch (e) {
      AppLogger.error('Error removing FCM token: $e');
    }
  }

  /// Send a local notification immediately (for testing)
  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF2E7D32),
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: data != null ? jsonEncode(data) : null,
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>(
  (_) => NotificationService(),
);
