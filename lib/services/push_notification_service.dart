import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

/// Handles Firebase push notification setup: initializing Firebase,
/// requesting notification permission, and registering the device's FCM
/// token with our backend so it can receive scheduled/engagement pushes.
class PushNotificationService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();

    final messaging = FirebaseMessaging.instance;

    // Ask the user for notification permission (required on Android 13+/iOS).
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get the current FCM token and send it to our backend.
    final token = await messaging.getToken();
    if (token != null) {
      await _registerTokenWithBackend(token);
    }

    // If the token ever refreshes (can happen), re-register it.
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _registerTokenWithBackend(newToken);
    });
  }

  static Future<void> _registerTokenWithBackend(String token) async {
    try {
      final headers = await ApiService.getHeaders();
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/device-token'),
            headers: headers,
            body: jsonEncode({
              'token': token,
              'platform': 'android',
            }),
          )
          .timeout(const Duration(seconds: 15));
      print('Device token register status: ${response.statusCode}');
    } catch (e) {
      print('Device token register failed: $e');
    }
  }
}
