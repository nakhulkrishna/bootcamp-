import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaming_center/features/device_management/data/model.dart';


class FirebaseServiceConsoles {
  FirebaseServiceConsoles._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'devices';

  ///  ADD CONSOLE
  static Future<void> addConsole(DeviceModel device) async {
    try {
      await _firestore.collection(_collection).add(device.toMap());
    } catch (e) {
      throw Exception('Failed to add console: $e');
    }
  }

  ///  UPDATE CONSOLE (full update)
  static Future<void> updateConsole(
    String deviceId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(deviceId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update console: $e');
    }
  }

  ///  DELETE CONSOLE
  static Future<void> deleteConsole(String deviceId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(deviceId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete console: $e');
    }
  }

  ///  MARK AS MAINTENANCE
  static Future<void> setMaintenance(
    String deviceId,
  ) async {
    try {
      await updateConsole(deviceId, {
        'status': DeviceStatus.maintenance.index,
        'deviceStatus':DeviceStatus.maintenance,
        'runningGame': null,
        'sessionStart': null,
        'sessionDuration': null,
      });
    } catch (e) {
      throw Exception('Failed to set maintenance: $e');
    }
  }

  // ///  START SESSION
  // static Future<void> startSession({
  //   required String deviceId,
  //   required String game,
  //   required int durationInSeconds,
  //   required String paymentMethod,
  // }) async {
  //   try {
  //     await updateConsole(deviceId, {
  //       'status': DeviceStatus.running.index,
  //       'runningGame': game,
  //       'sessionStart': DateTime.now().millisecondsSinceEpoch,
  //       'sessionDuration': durationInSeconds,
  //       'paymentMethod': paymentMethod,
  //       'isPaid': false,
  //     });
  //   } catch (e) {
  //     throw Exception('Failed to start session: $e');
  //   }
  // }

  ///  STOP SESSION
static Future<void> stopSession(String sessionId, String deviceId) async {
  final now = DateTime.now();

  final batch = _firestore.batch();

  batch.update(
    _firestore.collection('sessions').doc(sessionId),
    {
      'endTime': now.millisecondsSinceEpoch,
      'status': 'completed',
      'isPaid': true,
    },
  );

  batch.update(
    _firestore.collection('devices').doc(deviceId),
    {
      'status': DeviceStatus.free.index,
    },
  );

  await batch.commit();
}


static Future<void> startSession({
  required DeviceModel device,
  required String game,
  required int durationSeconds,
  required String paymentMethod,
}) async {
  final now = DateTime.now();

  final sessionRef =
      _firestore.collection('sessions').doc();

  final batch = _firestore.batch();

  // 1️⃣ Create session
  batch.set(sessionRef, {
    'deviceId': device.id,
    'deviceName': device.name,
    'game': game,
    'startTime': now.millisecondsSinceEpoch,
    'endTime': null,
    'duration': durationSeconds,
    'paymentMethod': paymentMethod,
    'isPaid': false,
    'status': 'running',
  });

  // 2️⃣ Update device only status
  batch.update(
    _firestore.collection('devices').doc(device.id),
    {
      'status': DeviceStatus.running.index,
    },
  );

  await batch.commit();
}

}
