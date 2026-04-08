import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaming_center/core/config/environment.dart';
import '../../device_management/data/model.dart';
int calculatePlayedPrice(Duration played, {int basePrice = 100, int baseDurationSec = 1800}) {
  final double pricePerSec = basePrice / baseDurationSec;
  final price = played.inSeconds * pricePerSec;
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
    required int price,
  }) async {
    log('Starting session: isPaid=$isPaid, duration=$durationSeconds');
    final now = DateTime.now();
    
    // An open session passes 0 for duration
    final bool isOpenSession = durationSeconds <= 0;
    final DateTime? endTime = isOpenSession ? null : now.add(Duration(seconds: durationSeconds));

    final deviceRef = _db.collection(EnvironmentConfig.collection('devices')).doc(device.id);
    final sessionRef = _db.collection(EnvironmentConfig.collection('sessions')).doc();

    await _db.runTransaction((transaction) async {
      // 1. Check if device is actually free to prevent race conditions
      final deviceSnap = await transaction.get(deviceRef);
      if (!deviceSnap.exists) {
        throw Exception("Device not found.");
      }
      
      final currentStatus = deviceSnap.data()?['status'] as int?;
      if (currentStatus != DeviceStatus.free.index) {
        throw Exception("Double booking prevented: Device is currently occupied or in maintenance.");
      }

      // 2. Write the session
      transaction.set(sessionRef, {
        'deviceId': device.id,
        'deviceName': device.name,
        'game': game,

        'startTime': now.millisecondsSinceEpoch,
        'endTime': endTime?.millisecondsSinceEpoch,
        'duration': durationSeconds,

        'paymentMethod': paymentMethod,
        'isPaid': isPaid,
        'status': 'running',
        'price': price, // Original requested price (important for fixed sessions)
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. Mark device as running
      transaction.update(deviceRef, {
        'status': DeviceStatus.running.index,
      });
    });
  }

  static Future<void> stopSession({
    required String sessionId,
    required String deviceId,
    int basePrice = 100,
    int baseDurationSec = 1800,
    bool forcePaid = false,
  }) async {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final sessionRef = _db.collection(EnvironmentConfig.collection('sessions')).doc(sessionId);
    final deviceRef = _db.collection(EnvironmentConfig.collection('devices')).doc(deviceId);

    await _db.runTransaction((transaction) async {
      final sessionSnap = await transaction.get(sessionRef);
      if (!sessionSnap.exists) return;

      final data = sessionSnap.data()!;
      // Prevent stopping an already completed session
      if (data['status'] == 'completed') return;

      final int startTimeMs = data['startTime'] ?? nowMs;
      final int originalDuration = data['duration'] ?? 0;
      final int originalPrice = data['price'] ?? 0;

      final bool isFixedSession = originalDuration > 0;

      int finalPrice;
      int playedSeconds = ((nowMs - startTimeMs) ~/ 1000).clamp(0, 24 * 3600);

      if (isFixedSession) {
        // FIXED RULE: If user booked 30 mins, they pay for 30 mins even if they leave early.
        finalPrice = originalPrice;
        // In fixed sessions, the played duration is clamped to not exceed the booked duration for reporting cleanups, 
        // but they still pay the full fixed price.
        playedSeconds = playedSeconds.clamp(0, originalDuration);
      } else {
        // OPEN SESSION RULE: Calculate price exactly by the played seconds.
        final start = DateTime.fromMillisecondsSinceEpoch(startTimeMs);
        final now = DateTime.now();
        final playedDuration = now.difference(start);
        finalPrice = calculatePlayedPrice(
          playedDuration, 
          basePrice: basePrice, 
          baseDurationSec: baseDurationSec
        );
      }

      transaction.update(sessionRef, {
        'endTime': nowMs,
        'duration': playedSeconds,   // Actual usage
        'price': finalPrice,         // Final price (Full price for fixed, calculated for open)
        'status': 'completed',
        if (forcePaid) 'isPaid': true,
      });

      transaction.update(deviceRef, {
        'status': DeviceStatus.free.index,
      });
    });
  }

  static Future<void> extendSession({
    required String sessionId,
    required int extraMinutes,
    required int extraPrice,
  }) async {
    final sessionRef = _db.collection(EnvironmentConfig.collection('sessions')).doc(sessionId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(sessionRef);

      if (!snapshot.exists) {
        throw Exception("Session not found");
      }

      final data = snapshot.data()!;
      if (data['status'] == 'completed') {
        throw Exception("Cannot extend a completed session");
      }

      // Calculate new time and price atomically
      final int currentEndTime = data['endTime'];
      final int currentDuration = data['duration'] ?? 0;
      final int currentPrice = data['price'] ?? 0;

      final int newEndTime = currentEndTime + Duration(minutes: extraMinutes).inMilliseconds;
      final int newDuration = currentDuration + Duration(minutes: extraMinutes).inSeconds;
      final int newPrice = currentPrice + extraPrice;

      transaction.update(sessionRef, {
        'endTime': newEndTime,
        'duration': newDuration,
        'price': newPrice,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> migrateSession({
    required String sessionId,
    required DeviceModel newDevice,
    required String oldDeviceId,
  }) async {
    final sessionRef = _db.collection(EnvironmentConfig.collection('sessions')).doc(sessionId);
    final oldDeviceRef = _db.collection(EnvironmentConfig.collection('devices')).doc(oldDeviceId);
    final newDeviceRef = _db.collection(EnvironmentConfig.collection('devices')).doc(newDevice.id);

    await _db.runTransaction((transaction) async {
      final sessionSnap = await transaction.get(sessionRef);
      if (!sessionSnap.exists) throw Exception("Session not found");

      final newDeviceSnap = await transaction.get(newDeviceRef);
      if (!newDeviceSnap.exists) throw Exception("Target device not found");

      final currentStatus = newDeviceSnap.data()?['status'] as int?;
      if (currentStatus != DeviceStatus.free.index) {
        throw Exception("Target device is not free.");
      }

      // 1. Update Session to point to new device
      transaction.update(sessionRef, {
        'deviceId': newDevice.id,
        'deviceName': newDevice.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Free up old device
      transaction.update(oldDeviceRef, {
        'status': DeviceStatus.free.index,
      });

      // 3. Occupy new device
      transaction.update(newDeviceRef, {
        'status': DeviceStatus.running.index,
      });
    });
  }
}
