import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Background message handler must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] Message received: ${message.messageId}');
  debugPrint('[FCM Background] Title: ${message.notification?.title}');
  debugPrint('[FCM Background] Body: ${message.notification?.body}');
  debugPrint('[FCM Background] Data: ${message.data}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    try {
      debugPrint('[NotificationService] Initializing...');

      // Request permission
      final settings = await _requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('[NotificationService] Permission not granted');
        return;
      }

      // Get FCM token
      await _getFCMToken();

      // Setup message handlers
      _setupMessageHandlers();

      // Listen to token refresh
      _setupTokenRefreshListener();

      debugPrint('[NotificationService] Initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('[NotificationService] Initialization error: $e');
      debugPrint('[NotificationService] Stack trace: $stackTrace');
    }
  }

  /// Request notification permission
  Future<NotificationSettings> _requestPermission() async {
    debugPrint('[NotificationService] Requesting permission...');
    
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('[NotificationService] Permission status: ${settings.authorizationStatus}');
    return settings;
  }

  /// Get FCM token
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('[NotificationService] FCM Token: $_fcmToken');

      // Save token to Firestore for current user
      if (_fcmToken != null) {
        await _saveTokenToFirestore(_fcmToken!);
      }

      return _fcmToken;
    } catch (e) {
      debugPrint('[NotificationService] Error getting FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('[NotificationService] No user logged in, skipping token save');
        return;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.toString(),
      }, SetOptions(merge: true));

      debugPrint('[NotificationService] Token saved to Firestore for user: ${user.uid}');
    } catch (e) {
      debugPrint('[NotificationService] Error saving token to Firestore: $e');
    }
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background messages (when app is in background but not terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Terminated state messages
    _checkInitialMessage();
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[FCM Foreground] Message received: ${message.messageId}');
    debugPrint('[FCM Foreground] Title: ${message.notification?.title}');
    debugPrint('[FCM Foreground] Body: ${message.notification?.body}');
    debugPrint('[FCM Foreground] Data: ${message.data}');

    // You can show a local notification here if needed
    // or update your app state
  }

  /// Handle message opened from background
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('[FCM Background Opened] Message: ${message.messageId}');
    debugPrint('[FCM Background Opened] Data: ${message.data}');

    // Navigate to specific screen based on message data
    _handleNotificationNavigation(message.data);
  }

  /// Check if app was opened from a terminated state via notification
  Future<void> _checkInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      debugPrint('[FCM Terminated] App opened from notification: ${message.messageId}');
      debugPrint('[FCM Terminated] Data: ${message.data}');
      
      // Handle navigation
      _handleNotificationNavigation(message.data);
    }
  }

  /// Handle notification navigation based on data
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    debugPrint('[NotificationService] Handling navigation with data: $data');

    // Example navigation logic
    // You can extend this based on your app's needs
    if (data.containsKey('screen')) {
      final screen = data['screen'];
      debugPrint('[NotificationService] Navigate to screen: $screen');
      
      // Add your navigation logic here
      // Example: context.go('/screen/$screen');
    }

    if (data.containsKey('examId')) {
      final examId = data['examId'];
      debugPrint('[NotificationService] Navigate to exam: $examId');
      
      // Example: context.go('/exam/$examId');
    }

    if (data.containsKey('questionId')) {
      final questionId = data['questionId'];
      debugPrint('[NotificationService] Navigate to question: $questionId');
      
      // Example: context.go('/question/$questionId');
    }
  }

  /// Setup token refresh listener
  void _setupTokenRefreshListener() {
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('[NotificationService] Token refreshed: $newToken');
      _fcmToken = newToken;
      _saveTokenToFirestore(newToken);
    });
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('[NotificationService] Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('[NotificationService] Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('[NotificationService] Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('[NotificationService] Error unsubscribing from topic $topic: $e');
    }
  }

  /// Delete FCM token (useful for logout)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
      debugPrint('[NotificationService] Token deleted');

      // Remove token from Firestore
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'fcmToken': FieldValue.delete(),
          'fcmTokenUpdatedAt': FieldValue.delete(),
        });
      }
    } catch (e) {
      debugPrint('[NotificationService] Error deleting token: $e');
    }
  }

  /// Refresh token manually
  Future<String?> refreshToken() async {
    try {
      await _messaging.deleteToken();
      return await _getFCMToken();
    } catch (e) {
      debugPrint('[NotificationService] Error refreshing token: $e');
      return null;
    }
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    return await _messaging.getNotificationSettings();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}