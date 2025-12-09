import 'package:cloud_firestore/cloud_firestore.dart';

enum DeviceStatus {
  free,
  running,
  maintenance,
}





class DeviceModel {
  final String id;
  final String name;
  final DeviceStatus status;
  final List<String> availableGames;

  DeviceModel({
    required this.id,
    required this.name,
    required this.status,
    required this.availableGames,
  });

  /// 🔹 Firestore → Model
  factory DeviceModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DeviceModel(
      id: doc.id,
      name: data['name'] ?? '',
      status: DeviceStatus.values[data['status'] ?? 0],
      availableGames: List<String>.from(data['availableGames'] ?? []),
    );
  }

  /// 🔹 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status.index,
      'availableGames': availableGames,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}



enum SessionStatus { running, completed }

class SessionModel {
  final String id;
  final String deviceId;
  final String deviceName;
  final String game;
  final int startTime; // milliseconds
  final int? endTime; // milliseconds (nullable)
  final int duration; // seconds
  final String paymentMethod;
  final bool isPaid;
  final int price;
  final SessionStatus status;

  SessionModel({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.game,
    required this.startTime,
    required this.duration,
    required this.paymentMethod,
    required this.isPaid,
    required this.status,
     required this.price,
    this.endTime,
  });

  /// 🔹 Firestore → Model
factory SessionModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc) {
  final data = doc.data()!;

  return SessionModel(
    id: doc.id,
    deviceId: data['deviceId'] as String? ?? '',
    deviceName: data['deviceName'] as String? ?? '',
    game: data['game'] as String? ?? '',

    // ✅ SAFE PARSING
    startTime: (data['startTime'] as int?) ?? 0,
    endTime: data['endTime'] as int?, // nullable is OK
    duration: (data['duration'] as int?) ?? 0,

    paymentMethod: data['paymentMethod'] as String? ?? '',
    isPaid: data['isPaid'] ?? false,

    status: data['status'] == 'completed'
        ? SessionStatus.completed
        : SessionStatus.running,
        price: data['price'] ?? 0
  );
}


  /// 🔹 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'game': game,
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'status': status == SessionStatus.running
          ? 'running'
          : 'completed',
          'price': price,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// ✅ Remaining time (seconds)
int get remainingSeconds {
  if (status == SessionStatus.completed || endTime == null) return 0;

  final now = DateTime.now().millisecondsSinceEpoch;
  final remaining = ((endTime! - now) ~/ 1000);

  return remaining > 0 ? remaining : 0;
}


  /// ✅ Elapsed time (seconds)
int get elapsedSeconds {
  final now = endTime ??
      DateTime.now().millisecondsSinceEpoch;

  return ((now - startTime) ~/ 1000).clamp(0, duration);
}

}

enum DeviceAction {
  extend,
  maintenance,
  delete,
}
