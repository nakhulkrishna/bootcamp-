import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaming_center/core/config/environment.dart';

class FirebaseServiceGames {
  FirebaseServiceGames._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _collection = EnvironmentConfig.collection('games');

  /// 🔹 ADD GAME
  static Future<void> addGame(String name, {String category = 'Standard'}) async {
    try {
      await _firestore.collection(_collection).add({
        'name': name,
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add game: $e');
    }
  }

  /// 🔹 DELETE GAME
  static Future<void> deleteGame(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete game: $e');
    }
  }
}
