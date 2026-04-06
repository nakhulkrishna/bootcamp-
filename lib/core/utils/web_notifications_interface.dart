abstract class WebNotifier {
  bool get isSupported;
  bool get isGranted;
  Future<bool> requestPermission();
  void notify(String title, String body);
}

WebNotifier createWebNotifier() => _StubWebNotifier();

class _StubWebNotifier implements WebNotifier {
  @override
  bool get isSupported => false;

  @override
  bool get isGranted => false;

  @override
  Future<bool> requestPermission() async => false;

  @override
  void notify(String title, String body) {}
}
