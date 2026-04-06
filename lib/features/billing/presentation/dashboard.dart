import 'package:flutter/material.dart';
import 'package:gaming_center/features/billing/widget/widgets.dart';
import 'package:gaming_center/core/utils/formatters.dart';
import 'package:gaming_center/features/reports/provider/reports_provider.dart';
import 'package:gaming_center/features/device_management/providers/session_provider.dart';
import 'package:gaming_center/features/settings/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final from = DateTime(now.year, 1, 1);

    Future.microtask(() {
      if (!mounted) return;
      context.read<ReportsProvider>().loadReports(from: from, to: now);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsProvider>();
    return SingleChildScrollView(
      child: Container(
        color: const Color(0xFFF3F4F6), // Match reference light grey background
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  final currency = settings.settings.currencySymbol;
                  return Column(
                    children: [
                      // ✅ Top Alert Banner
                      AlertBanner(revenue: formatMoney(reports.todayRevenue, currencySymbol: currency)),
                      const SizedBox(height: 32),

                      // ✅ Stats cards row
                      Row(
                        children: [
                          Expanded(
                            child: ReferenceStatCard(
                              title: "Total Revenue",
                              value: formatMoney(reports.totalRevenue, currencySymbol: currency),
                              icon: Icons.receipt_long,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Consumer<SessionProvider>(
                              builder: (context, sessionProvider, _) {
                                return ReferenceStatCard(
                                  title: "Active Sessions",
                                  value: sessionProvider.sessions.length.toString(),
                                  icon: Icons.people_outline,
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: ReferenceStatCard(
                              title: "Completed Sessions",
                              value: reports.completedSessionsToday.toString(),
                              icon: Icons.check_circle_outline,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: ReferenceStatCard(
                              title: "Net Profit",
                              value: formatMoney(reports.netProfit, currencySymbol: currency),
                              icon: Icons.account_balance_wallet_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // ✅ Bottom Two Columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: On Going Task (Recent Activity)
                  const Expanded(
                    flex: 12,
                    child: ReferenceRecentActivityWidget(),
                  ),
                  const SizedBox(width: 32),
                  // Right Column: Charts
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: const [
                        PaymentsChart(),
                        SizedBox(height: 32),
                        ScreenTimeChart(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
