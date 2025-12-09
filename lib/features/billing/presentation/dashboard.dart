import 'package:flutter/material.dart';
import 'package:gaming_center/core/constants/colors.dart';
import 'package:gaming_center/features/billing/widget/gaming_footer.dart';
import 'package:gaming_center/features/billing/widget/widgets.dart';
import 'package:gaming_center/features/reports/provider/reports_provider.dart';
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
      context.read<ReportsProvider>().loadReports(from: from, to: now);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsProvider>();
    return SingleChildScrollView(
      child: Row(
        children: [
          // // ✅ Sidebar
          // SideBar(),

          // // ✅ Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ✅ Stats cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    crossAxisSpacing: 50,
                    mainAxisSpacing: 50,
                    childAspectRatio: 2,
                    children: [
                      DashboardCard(
                        title: "Total Revenue",
                        value: "₹ ${reports.totalRevenue.toStringAsFixed(0)}",
                        icon: Icons.trending_up,
                      ),
                      DashboardCard(
                        title: "Today Revenue",
                        value: "₹ ${reports.todayRevenue.toStringAsFixed(0)}",
                        icon: Icons.today,
                      ),
                      DashboardCard(
                        title: "Active Sessions",
                        value: reports.activeSessions.toString(),
                        icon: Icons.play_circle_fill,
                      ),
                      DashboardCard(
                        title: "Net Profit",
                        value: "₹ ${reports.netProfit.toStringAsFixed(0)}",
                        icon: Icons.account_balance_wallet,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // ✅ Charts row
                  Row(
                    children: const [
                      Expanded(child: ScreenTimeChart()),
                      SizedBox(width: 32),
                      Expanded(child: PaymentsChart()),
                    ],
                  ),
                    const GamingFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
