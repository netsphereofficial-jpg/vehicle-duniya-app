import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Service for handling push notifications
class NotificationService {
  final FirebaseMessaging _messaging;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  NotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  /// Initialize notification service
  Future<void> initialize() async {
    // Request permission
    await requestPermission();

    // Get FCM token
    final token = await getToken();
    AppLogger.info('NotificationService', 'FCM Token: $token');

    // Handle foreground messages
    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when app is opened from notification
    _openedAppSubscription =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleInitialMessage(initialMessage);
    }
  }

  /// Request notification permission
  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    AppLogger.info(
      'NotificationService',
      'Permission status: ${settings.authorizationStatus}',
    );

    return settings;
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      AppLogger.error('NotificationService', 'Error getting FCM token', error: e);
      return null;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      AppLogger.info('NotificationService', 'Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.error(
        'NotificationService',
        'Error subscribing to topic: $topic',
        error: e,
      );
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      AppLogger.info('NotificationService', 'Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.error(
        'NotificationService',
        'Error unsubscribing from topic: $topic',
        error: e,
      );
    }
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info(
      'NotificationService',
      'Foreground message: ${message.notification?.title}',
    );

    // TODO: Show local notification or in-app alert
    if (kDebugMode) {
      print('Foreground Message:');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
    }
  }

  /// Handle message when app is opened from notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    AppLogger.info(
      'NotificationService',
      'Message opened app: ${message.notification?.title}',
    );

    // TODO: Navigate to appropriate screen based on message data
    _processNotificationData(message.data);
  }

  /// Handle initial message (app opened from terminated state)
  void _handleInitialMessage(RemoteMessage message) {
    AppLogger.info(
      'NotificationService',
      'Initial message: ${message.notification?.title}',
    );

    _processNotificationData(message.data);
  }

  /// Process notification data and navigate accordingly
  void _processNotificationData(Map<String, dynamic> data) {
    final type = data['type'];
    final id = data['id'];

    switch (type) {
      case 'auction':
        // Navigate to auction detail
        AppLogger.info('NotificationService', 'Navigate to auction: $id');
        break;
      case 'bid':
        // Navigate to bid detail
        AppLogger.info('NotificationService', 'Navigate to bid: $id');
        break;
      case 'payment':
        // Navigate to payment
        AppLogger.info('NotificationService', 'Navigate to payment: $id');
        break;
      default:
        AppLogger.info('NotificationService', 'Unknown notification type: $type');
    }
  }

  /// Dispose subscriptions
  void dispose() {
    _foregroundSubscription?.cancel();
    _openedAppSubscription?.cancel();
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info(
    'NotificationService',
    'Background message: ${message.notification?.title}',
  );
}
