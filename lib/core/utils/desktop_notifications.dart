import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class DesktopNotifier {
  DesktopNotifier._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      const windows = WindowsInitializationSettings(
        appName: 'Gaming Center',
        appUserModelId: 'com.bootcamp.gaming_center',
        guid: '2c5a7b1b-7a1b-4b1a-9c1a-1a2b3c4d5e6f',
      );
      final settings = InitializationSettings(windows: windows);
      await _plugin.initialize(settings: settings);
    }
  }

  static Future<void> notify({
    required String title,
    required String body,
  }) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      final details = NotificationDetails(
        windows: WindowsNotificationDetails(),
      );
      await _plugin.show(
        id: 0,
        title: title,
        body: body,
        notificationDetails: details,
      );
    }
  }
}
