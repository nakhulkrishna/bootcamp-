import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaming_center/core/config/environment.dart';
import '../data/settings_model.dart';

class FirebaseServiceSettings {
  FirebaseServiceSettings._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _collection = EnvironmentConfig.collection('settings');
  static const String _docId = 'global_config';

  static Future<SettingsModel> getSettings() async {
    try {
      final doc = await _firestore.collection(_collection).doc(_docId).get();
      if (doc.exists && doc.data() != null) {
        return SettingsModel.fromMap(doc.data()!);
      }
      // Default settings if none exist
      return SettingsModel(pricing: {
        'Standard': {
          '1800': 100,
          '3600': 150,
          '7200': 200,
        },
        'VR': {
          '1800': 200,
          '3600': 350,
        },
      });
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }

  static Future<void> saveSettings(SettingsModel settings) async {
    try {
      await _firestore.collection(_collection).doc(_docId).set(settings.toMap());
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }
}
