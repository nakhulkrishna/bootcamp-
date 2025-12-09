import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../device_management/data/model.dart';

class FirebaseSessionService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> startSession({
    required DeviceModel device,
    required String game,
    required int durationSeconds,
    required String paymentMethod,
    required bool isPaid,
    required int price
  }) async {
    log(isPaid.toString());
    final now = DateTime.now();
    final endTime = now.add(Duration(seconds: durationSeconds));

    final batch = _db.batch();
    final sessionRef = _db.collection('sessions').doc();

    batch.set(sessionRef, {
      'deviceId': device.id,
      'deviceName': device.name,
      'game': game,

      // ✅ STORE ABSOLUTE TIME
      'startTime': now.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,

      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'status': 'running',
      'price':price,

      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(_db.collection('devices').doc(device.id), {
      'status': DeviceStatus.running.index,
    });

    await batch.commit();
  }

  static Future<void> stopSession({
    required String sessionId,
    required String deviceId,
  }) async {
    final now = DateTime.now();
    final batch = _db.batch();

    batch.update(_db.collection('sessions').doc(sessionId), {
      'endTime': now.millisecondsSinceEpoch,
      'status': 'completed',
    });

    batch.update(_db.collection('devices').doc(deviceId), {
      'status': DeviceStatus.free.index,
    });

    await batch.commit();
  }

  static Future<void> extendSession({
    required String sessionId,
    required int extraMinutes,
  }) async {
    final sessionRef = _db.collection('sessions').doc(sessionId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(sessionRef);

      if (!snapshot.exists) {
        throw Exception("Session not found");
      }

      final data = snapshot.data()!;
      final int currentEndTime = data['endTime'];

      final int newEndTime =
          currentEndTime + Duration(minutes: extraMinutes).inMilliseconds;

      transaction.update(sessionRef, {
        'endTime': newEndTime,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
