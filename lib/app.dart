import 'package:flutter/material.dart';
import 'package:gaming_center/core/constants/colors.dart';
import 'package:gaming_center/features/billing/presentation/dashboard.dart';
import 'package:gaming_center/features/billing/widget/widgets.dart';
import 'package:gaming_center/features/device_management/presentation/device_management.dart';
import 'package:gaming_center/features/device_management/presentation/session_management.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const devices = '/devices';
  static const reports = '/reports';
  static const billing = '/billing';
  static const settings = '/settings';
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.dashboard:
        return _page(const DashboardScreen());

      case AppRoutes.devices:
        return _page(const DeviceScreen());

      default:
        return _page(const DashboardScreen());
    }
  }

  static MaterialPageRoute _page(Widget child) {
    return MaterialPageRoute(builder: (_) => child);
  }
}
class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          const SideBar(),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(
                  child: Consumer<NavigationProvider>(
                    builder: (context, nav, _) {
                      return _buildBody(nav.current);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppSection section) {
    switch (section) {
      case AppSection.dashboard:
        return const DashboardScreen();

      case AppSection.devices:
        return const DeviceScreen();
        case AppSection.sessions:
        return const SessionManagement();

      case AppSection.billing:
        return const DeviceScreen();
      case AppSection.reports:
        return const DeviceScreen();

      case AppSection.settings:
        return const DeviceScreen();
    }
  }
}

enum AppSection { dashboard, devices,sessions ,billing, reports, settings }

class NavigationProvider extends ChangeNotifier {
  AppSection _current = AppSection.dashboard;

  AppSection get current => _current;

  void setSection(AppSection section) {
    if (_current != section) {
      _current = section;
      notifyListeners();
    }
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainLayout(),
    );
  }
}


