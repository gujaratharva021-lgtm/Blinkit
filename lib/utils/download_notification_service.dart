import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';

/// Shows a native "Download complete" style notification after a file has
/// been saved to the device, similar to how browsers/downloads managers
/// notify the user. Tapping the notification opens the saved file.
class DownloadNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final path = response.payload;
        if (path != null && path.isNotEmpty) {
          OpenFilex.open(path);
        }
      },
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'downloads_channel',
        'Downloads',
        description: 'Notifies when a file finishes downloading',
        importance: Importance.high,
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  static Future<void> showDownloadComplete({
    required String fileName,
    required String filePath,
  }) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'downloads_channel',
      'Downloads',
      channelDescription: 'Notifies when a file finishes downloading',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: fileName.hashCode,
      title: 'Download complete',
      body: fileName,
      notificationDetails: details,
      payload: filePath,
    );
  }
}
