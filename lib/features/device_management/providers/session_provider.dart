import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaming_center/features/device_management/data/model.dart';
import 'package:gaming_center/features/device_management/domain/firebase_service_sessions.dart';


class SessionProvider extends ChangeNotifier {
  final List<SessionModel> _sessions = [];
  StreamSubscription? _subscription;

  List<SessionModel> get sessions => _sessions;

  void listenActiveSessions() {
    _subscription = FirebaseFirestore.instance
        .collection('sessions')
        .where('status', isEqualTo: 'running')
        .snapshots()
        .listen((snapshot) {
      _sessions
        ..clear()
        ..addAll(snapshot.docs.map(SessionModel.fromFirestore));
      notifyListeners();
    });
  }

  Future<void> startSession({
    required DeviceModel device,
    required String game,
    required int durationSeconds,
    required String paymentMethod,
    required bool isPaid,
    required int price
  }) {
    return FirebaseSessionService.startSession(
      device: device,
      game: game,
      durationSeconds: durationSeconds,
      paymentMethod: paymentMethod,
      isPaid: isPaid,
      price: price
    );
  }

  Future<void> stopSession({
    required String sessionId,
    required String deviceId,
  }) {
    return FirebaseSessionService.stopSession(
      sessionId: sessionId,
      deviceId: deviceId,
    );
  }

  SessionModel? getRunningSessionForDevice(String deviceId) {
  try {
    return sessions.firstWhere(
      (s) => s.deviceId == deviceId && s.status == SessionStatus.running,
    );
  } catch (_) {
    return null;
  }
}
  Timer? _timer;

  SessionProvider() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
        _subscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }
  final AudioPlayer _player = AudioPlayer();

Future<void> unlockAudio() async {
  await _player.setVolume(0);
  await _player.play(AssetSource('sounds/time_over.mp3'));
  await _player.stop();
  await _player.setVolume(1);
}

  static const Map<int, int> extendPricing = {
    30: 100,
    60: 200,
    120: 400,
  };

  Future<void> extendSession(String sessionId, int extraMinutes) async {
    final extraPrice = extendPricing[extraMinutes] ?? 0;

    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(sessionId)
        .update({
      'duration': FieldValue.increment(extraMinutes * 60),
      'price': FieldValue.increment(extraPrice),
      'endTime': FieldValue.increment(extraMinutes * 60 * 1000),
    });

    notifyListeners();
  }
}
