import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaming_center/core/config/environment.dart';

class FirestoreResetService {
  FirestoreResetService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> wipeAllData() async {
    await _deleteCollection(EnvironmentConfig.collection('sessions'));
    await _deleteCollection(EnvironmentConfig.collection('devices'));
    await _deleteCollection(EnvironmentConfig.collection('expenses'));
    await _deleteCollection(EnvironmentConfig.collection('games'));

    // Remove global settings doc (will fall back to defaults on next load)
    await _db.collection(EnvironmentConfig.collection('settings')).doc('global_config').delete();
  }

  static Future<void> _deleteCollection(String name) async {
    const int batchSize = 400;
    while (true) {
      final snapshot = await _db.collection(name).limit(batchSize).get();
      if (snapshot.docs.isEmpty) break;

      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      if (snapshot.docs.length < batchSize) break;
    }
  }
}
