import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gorevde_yukselme/core/services/notification_service.dart';

/// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// FCM Token Provider
final fcmTokenProvider = StateProvider<String?>((ref) {
  return ref.watch(notificationServiceProvider).fcmToken;
});

/// Notification Enabled Provider
final notificationsEnabledProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(notificationServiceProvider).areNotificationsEnabled();
});