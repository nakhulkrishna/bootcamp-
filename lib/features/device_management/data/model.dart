import 'package:cloud_firestore/cloud_firestore.dart';

enum DeviceStatus {
  free,
  running,
  maintenance,
}

enum DeviceType {
  ps5,
  ps4,
  xboxSeriesX,
  xboxSeriesS,
  pc,
  nintendoSwitch,
  other,
}

class DeviceModel {
  final String id;
  final String name;
  final DeviceStatus status;
  final DeviceType type;
  final List<String> availableGames;

  DeviceModel({
    required this.id,
    required this.name,
    required this.status,
    required this.type,
    required this.availableGames,
  });

  /// 🔹 Firestore → Model
  factory DeviceModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DeviceModel(
      id: doc.id,
      name: data['name'] ?? '',
      status: DeviceStatus.values[(data['status'] as int?) ?? 0],
      type: DeviceType.values[(data['type'] as int?) ?? DeviceType.other.index],
      availableGames: List<String>.from(data['availableGames'] ?? []),
    );
  }

  /// 🔹 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status.index,
      'type': type.index,
      'availableGames': availableGames,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// ✅ copyWith (for Edit / Updates)
  DeviceModel copyWith({
    String? id,
    String? name,
    DeviceStatus? status,
    DeviceType? type,
    List<String>? availableGames,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      type: type ?? this.type,
      availableGames: availableGames ?? List.from(this.availableGames),
    );
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
      startTime: (data['startTime'] as int?) ?? 0,
      endTime: data['endTime'] as int?,
      duration: (data['duration'] as int?) ?? 0,
      paymentMethod: data['paymentMethod'] as String? ?? '',
      isPaid: data['isPaid'] ?? false,
      status: data['status'] == 'completed'
          ? SessionStatus.completed
          : SessionStatus.running,
      price: data['price'] ?? 0,
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
      'status': status == SessionStatus.running ? 'running' : 'completed',
      'price': price,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// ✅ Remaining time (seconds)
  int get remainingSeconds {
    if (status == SessionStatus.completed) return 0;
    if (endTime == null) return -1; // -1 means open-ended session

    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = ((endTime! - now) ~/ 1000);

    return remaining > 0 ? remaining : 0;
  }

  /// ✅ Elapsed time (seconds)
  int get elapsedSeconds {
    final now = endTime ?? DateTime.now().millisecondsSinceEpoch;

    return ((now - startTime) ~/ 1000).clamp(0, duration);
  }
}

enum DeviceAction {
  extend,
  maintenance,
  delete,
}
