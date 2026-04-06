import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gaming_center/features/device_management/providers/console_provider.dart';
import 'package:gaming_center/features/device_management/providers/session_provider.dart';
import 'package:gaming_center/features/device_management/providers/game_provider.dart';
import 'package:gaming_center/features/reports/provider/reports_provider.dart';
import 'package:gaming_center/features/settings/providers/settings_provider.dart';
import 'package:gaming_center/features/expenses/providers/expense_provider.dart';
import 'package:gaming_center/firebase_options.dart';
import 'package:provider/provider.dart';

import 'package:gaming_center/core/config/environment.dart';

import 'package:gaming_center/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Automatically use Production collections when deployed, and Dev when testing locally.
  EnvironmentConfig.set(kReleaseMode ? AppEnvironment.prod : AppEnvironment.dev);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ Navigation (sidebar)
        ChangeNotifierProvider(create: (_) => NavigationProvider()),

        // ✅ Console / Device providers
        ChangeNotifierProvider(
          create: (_) => DeviceProvider()..startListening(),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionProvider()..listenActiveSessions(),
        ),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: const App(),
    );
  }
}
