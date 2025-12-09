import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaming_center/features/device_management/domain/firebase_service_consoles.dart';
import '../data/model.dart';


class DeviceProvider extends ChangeNotifier {
  final List<DeviceModel> _devices = [];
  StreamSubscription? _subscription;

  bool _loading = false;
  String? _error;

  List<DeviceModel> get devices => _devices;
  bool get loading => _loading;
  String? get error => _error;

  void startListening() {
    _loading = true;
    notifyListeners();

    _subscription = FirebaseFirestore.instance
        .collection('devices')
        .snapshots()
        .listen(
      (snapshot) {
        _devices
          ..clear()
          ..addAll(snapshot.docs.map(DeviceModel.fromFirestore));

        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _loading = false;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> addDevice(DeviceModel device) {
    return FirebaseServiceConsoles.addConsole(device);
  }

  Future<void> deleteDevice(String id) {
    return FirebaseServiceConsoles.deleteConsole(id);
  }

  Future<void> setMaintenance(String id) {
    return FirebaseServiceConsoles.setMaintenance(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
