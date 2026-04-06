import 'package:flutter/material.dart';
import '../data/settings_model.dart';
import '../domain/firebase_service_settings.dart';

class SettingsProvider with ChangeNotifier {
  SettingsModel _settings = SettingsModel(pricing: {
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
  bool _loading = false;

  SettingsModel get settings => _settings;
  bool get loading => _loading;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _loading = true;
    notifyListeners();
    try {
      _settings = await FirebaseServiceSettings.getSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(SettingsModel newSettings) async {
    _settings = newSettings;
    notifyListeners();
    try {
      await FirebaseServiceSettings.saveSettings(newSettings);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }
}
