enum AppEnvironment { prod, dev }

class EnvironmentConfig {
  static AppEnvironment _current = AppEnvironment.dev; // Default to dev for safety

  static AppEnvironment get current => _current;

  static void set(AppEnvironment env) {
    _current = env;
  }

  static bool get isDev => _current == AppEnvironment.dev;

  /// Returns a collection name with a prefix if in dev mode
  static String collection(String name) {
    return isDev ? 'dev_$name' : name;
  }
}
