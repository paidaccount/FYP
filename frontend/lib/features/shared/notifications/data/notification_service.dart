import 'package:dio/dio.dart';

class NotificationService {
  final Dio _dio;
  final String _baseUrl;

  NotificationService({required Dio dio, String baseUrl = 'http://localhost:8000/api/v1'})
      : _dio = dio,
        _baseUrl = baseUrl;

  /// Registers the mobile device's FCM token with the backend.
  Future<bool> registerDeviceToken({
    required String userId,
    required String token,
    String platform = 'android',
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/notifications/register-token',
        data: {
          'user_id': userId,
          'token': token,
          'platform': platform,
        },
      );
      return response.statusCode == 201;
    } catch (e) {
      // Gracefully log network errors
      print('Failed registering device token: $e');
      return false;
    }
  }

  /// Fetches the notifications history from the backend audit logs.
  Future<List<Map<String, dynamic>>> fetchNotificationHistory() async {
    try {
      final response = await _dio.get('$_baseUrl/notifications/history');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      print('Failed fetching notification history: $e');
      return [];
    }
  }

  /// Marks a specific notification as read.
  Future<bool> markAsRead(String id) async {
    try {
      final response = await _dio.put('$_baseUrl/notifications/read/$id');
      return response.statusCode == 200;
    } catch (e) {
      print('Failed marking notification as read: $e');
      return false;
    }
  }
}
