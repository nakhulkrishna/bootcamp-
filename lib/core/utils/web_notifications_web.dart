// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
export 'web_notifications_interface.dart';
import 'web_notifications_interface.dart';

class WebNotifierImpl implements WebNotifier {
  @override
  bool get isSupported => html.Notification.supported;

  @override
  bool get isGranted => html.Notification.permission == 'granted';

  @override
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    if (isGranted) return true;
    final permission = await html.Notification.requestPermission();
    return permission == 'granted';
  }

  @override
  void notify(String title, String body) {
    if (!isSupported || !isGranted) return;
    html.Notification(title, body: body);
  }
}

WebNotifier createWebNotifier() => WebNotifierImpl();
