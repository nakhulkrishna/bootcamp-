import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gaming_center/features/device_management/providers/console_provider.dart';
import 'package:gaming_center/features/device_management/providers/session_provider.dart';
import 'package:gaming_center/features/reports/presentation/reports_screen.dart';
import 'package:gaming_center/features/reports/provider/reports_provider.dart';
import 'package:gaming_center/firebase_options.dart';
import 'package:gaming_center/shared/providers/console_provider.dart';
import 'package:provider/provider.dart';

import 'package:gaming_center/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

        // ✅ Console / Device provider (THIS WAS MISSING)
        ChangeNotifierProvider(
          create: (_) => DeviceProvider()..startListening(),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionProvider()..listenActiveSessions(),
        ),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
      ],
      child: const App(),
    );
  }
}
