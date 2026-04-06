import 'package:flutter/material.dart';
import 'package:gaming_center/core/constants/colors.dart';
import 'package:gaming_center/features/billing/presentation/dashboard.dart';
import 'package:gaming_center/features/billing/widget/widgets.dart';
import 'package:gaming_center/features/device_management/presentation/device_management.dart';
import 'package:gaming_center/features/device_management/presentation/session_management.dart';
import 'package:gaming_center/features/reports/presentation/reports_screen.dart';
import 'package:gaming_center/features/settings/presentation/settings_screen.dart';
import 'package:gaming_center/features/expenses/presentation/expense_screen.dart';
import 'package:gaming_center/core/config/environment.dart';
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
          const SlimSidebar(),
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

      case AppSection.reports:
        return const ReportsScreen();

      case AppSection.settings:
        return const SettingsScreen();

      case AppSection.expenses:
        return const ExpenseScreen();
    }
  }
}

enum AppSection { dashboard, devices, sessions, reports, settings, expenses }

enum UserRole { admin, receptionist }

class NavigationProvider extends ChangeNotifier {
  AppSection _current = AppSection.dashboard;
  UserRole _role = UserRole.admin;

  AppSection get current => _current;
  UserRole get role => _role;

  void setSection(AppSection section) {
    if (_role == UserRole.receptionist &&
        (section == AppSection.settings ||
            section == AppSection.reports ||
            section == AppSection.expenses)) {
      return;
    }
    if (_current != section) {
      _current = section;
      notifyListeners();
    }
  }

  void toggleRole() {
    _role = _role == UserRole.admin ? UserRole.receptionist : UserRole.admin;

    // If switching to receptionist, redirect if on restricted page
    if (_role == UserRole.receptionist &&
        (_current == AppSection.settings ||
            _current == AppSection.reports ||
            _current == AppSection.expenses)) {
      _current = AppSection.dashboard;
    }
    notifyListeners();
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        dividerColor: AppColors.border,
        cardColor: AppColors.surface,
      ),
      builder: (context, child) {
        if (!EnvironmentConfig.isDev) return child!;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Banner(
            location: BannerLocation.topEnd,
            message: "DEV",
            color: Colors.orange,
            child: child!,
          ),
        );
      },
      home: const MainLayout(),
    );
  }
}
