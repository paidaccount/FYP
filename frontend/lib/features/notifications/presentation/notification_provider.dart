import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vanet_mobile/features/notifications/data/notification_service.dart';

class NotificationState extends StateNotifier<List<Map<String, dynamic>>> {
  final NotificationService _service;
  String? _fcmToken;

  NotificationState(this._service) : super([]) {
    loadHistory();
  }

  String? get fcmToken => _fcmToken;

  /// Loads notification logs from backend.
  Future<void> loadHistory() async {
    final history = await _service.fetchNotificationHistory();
    state = history;
  }

  /// Toggles read status for an item.
  Future<void> markAsRead(String id) async {
    final success = await _service.markAsRead(id);
    if (success) {
      state = state.map((item) {
        if (item['id'] == id) {
          return {...item, 'is_read': true};
        }
        return item;
      }).toList();
    }
  }

  /// Appends a new message directly to list state.
  void addNewNotification(Map<String, dynamic> notification) {
    state = [notification, ...state];
  }

  /// Configures Firebase Messaging listeners and registers token on backend.
  Future<void> initFirebaseMessaging(String userId) async {
    try {
      final messaging = FirebaseMessaging.instance;
      
      // Request permission
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      // Get device FCM token
      _fcmToken = await messaging.getToken();
      if (_fcmToken != null) {
        print('FCM Token generated: $_fcmToken');
        await _service.registerDeviceToken(
          userId: userId,
          token: _fcmToken!,
        );
      }

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('FCM foreground message received: ${message.notification?.title}');
        final data = message.data;
        addNewNotification({
          'id': message.messageId ?? DateTime.now().toString(),
          'title': message.notification?.title ?? 'VANET Alert',
          'message': message.notification?.body ?? '',
          'notification_type': data['notification_type'] ?? 'TRAFFIC',
          'priority': data['priority'] ?? 'MEDIUM',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      });

      // Background message click handler
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('FCM background click opened app: ${message.notification?.title}');
      });

    } catch (e) {
      print('Firebase messaging initialization bypassed/failed (Mock Mode): $e');
      
      // Seed mock token to verify backend API registration functions in sandboxes
      _fcmToken = 'MOCK_TOKEN_ANDROID_CLIENT_VANET_ID_99999';
      await _service.registerDeviceToken(
        userId: userId,
        token: _fcmToken!,
      );
    }
  }
}

// Global provider mapping Dio clients
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(dio: Dio());
});

final notificationProvider = StateNotifierProvider<NotificationState, List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationState(service);
});
