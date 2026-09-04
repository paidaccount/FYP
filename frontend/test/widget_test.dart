import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:vanet_mobile/features/notifications/data/notification_service.dart';
import 'package:vanet_mobile/features/notifications/presentation/notification_provider.dart';
import 'package:vanet_mobile/features/notifications/presentation/notification_screen.dart';

class FakeNotificationService extends NotificationService {
  FakeNotificationService() : super(dio: Dio());

  @override
  Future<List<Map<String, dynamic>>> fetchNotificationHistory() async {
    return [];
  }

  @override
  Future<bool> registerDeviceToken({
    required String userId,
    required String token,
    String platform = 'android',
  }) async {
    return true;
  }

  @override
  Future<bool> markAsRead(String id) async {
    return true;
  }
}

void main() {
  group('VANET Security App Provider Tests', () {
    test('Notification Provider initial state is empty', () {
      final container = ProviderContainer(
        overrides: [
          notificationServiceProvider.overrideWithValue(FakeNotificationService()),
        ],
      );
      addTearDown(container.dispose);
      
      final notifications = container.read(notificationProvider);
      expect(notifications, isEmpty);
    });

    test('Add local notification updates provider state', () {
      final container = ProviderContainer(
        overrides: [
          notificationServiceProvider.overrideWithValue(FakeNotificationService()),
        ],
      );
      addTearDown(container.dispose);
      
      final notifier = container.read(notificationProvider.notifier);
      
      notifier.addNewNotification({
        'id': 'test_alert_id',
        'title': 'Test Warning',
        'message': 'Sybil attack warning payload.',
        'notification_type': 'SECURITY',
        'priority': 'HIGH',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      final list = container.read(notificationProvider);
      expect(list.length, equals(1));
      expect(list.first['title'], equals('Test Warning'));
    });
  });

  group('VANET Dashboard Alerts Screen Widget Tests', () {
    testWidgets('Displays empty alert view when notifications list is empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider.overrideWithValue(FakeNotificationService()),
          ],
          child: const MaterialApp(
            home: NotificationScreen(),
          ),
        ),
      );

      // Check if title is displayed
      expect(find.text('VANET Security Alerts'), findsOneWidget);
      // Check if empty state message is present
      expect(find.text('No alerts registered.'), findsOneWidget);
    });

    testWidgets('Filter chip selection updates display filters', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider.overrideWithValue(FakeNotificationService()),
          ],
          child: const MaterialApp(
            home: NotificationScreen(),
          ),
        ),
      );

      // Verify that ChoiceChips are present
      expect(find.text('All Alerts'), findsOneWidget);
      expect(find.text('Security Warnings'), findsOneWidget);

      // Tap on the Security Warnings filter chip
      await tester.tap(find.text('Security Warnings'));
      await tester.pumpAndSettle();
    });
  });
}
