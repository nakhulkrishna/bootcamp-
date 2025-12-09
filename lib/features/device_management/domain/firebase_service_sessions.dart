import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../device_management/data/model.dart';
const int BASE_DURATION_SEC = 30 * 60; // 1800 seconds
const int BASE_PRICE = 100;            // ₹100
const double PRICE_PER_SECOND = BASE_PRICE / BASE_DURATION_SEC;
// 100 / 1800 = 0.0555 ₹ per second

int calculatePlayedPrice(Duration played) {
  final price = played.inSeconds * PRICE_PER_SECOND;
  return price.round(); // ✅ round to nearest rupee
}

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
  final nowMs = DateTime.now().millisecondsSinceEpoch;
  final batch = _db.batch();

  final sessionRef = _db.collection('sessions').doc(sessionId);
  final sessionSnap = await sessionRef.get();

  if (!sessionSnap.exists) return;

  final data = sessionSnap.data()!;

  final int startTimeMs = data['startTime'] ?? nowMs;

  // ✅ ACTUAL PLAYED TIME
  final playedSeconds =
      ((nowMs - startTimeMs) ~/ 1000).clamp(0, 24 * 3600);
final start = DateTime.fromMillisecondsSinceEpoch(startTimeMs);
final now = DateTime.now();

  final playedMinutes = (playedSeconds / 60).ceil(); // ✅ round UP
final playedDuration = now.difference(start);
  // ✅ ONLY PLAYED TIME PRICE
final finalPrice = calculatePlayedPrice(playedDuration);

  batch.update(sessionRef, {
    'endTime': nowMs,
    'duration': playedSeconds,   // ✅ real usage
    'price': finalPrice,         // ✅ real price
    'status': 'completed',
    'isPaid': true,
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
