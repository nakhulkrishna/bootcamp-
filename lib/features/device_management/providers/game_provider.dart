import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaming_center/core/config/environment.dart';
import '../data/game_model.dart';
import '../domain/firebase_service_games.dart';

class GameProvider extends ChangeNotifier {
  final List<GameModel> _games = [];
  StreamSubscription? _subscription;

  bool _loading = false;
  String? _error;

  List<GameModel> get games => _games;
  bool get loading => _loading;
  String? get error => _error;

  GameProvider() {
    startListening();
  }

  void startListening() {
    _loading = true;
    notifyListeners();

    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection(EnvironmentConfig.collection('games'))
        .orderBy('name')
        .snapshots()
        .listen(
      (snapshot) {
        _games
          ..clear()
          ..addAll(snapshot.docs.map(GameModel.fromFirestore));

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

  Future<void> addGame(String name, {String category = 'Standard'}) {
    return FirebaseServiceGames.addGame(name, category: category);
  }

  Future<void> deleteGame(String id) {
    return FirebaseServiceGames.deleteGame(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
