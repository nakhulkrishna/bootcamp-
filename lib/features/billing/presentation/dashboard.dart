import 'package:flutter/material.dart';
import 'package:gaming_center/core/constants/colors.dart';
import 'package:gaming_center/features/billing/widget/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      children: const [
                        DashboardCard(
                          title: "Total Devices",
                          value: "12",
                          icon: Icons.devices,
                        ),
                        DashboardCard(
                          title: "Active Sessions",
                          value: "5",
                          icon: Icons.play_circle_fill,
                        ),
                        DashboardCard(
                          title: "Today Revenue",
                          value: "₹3,200",
                          icon: Icons.currency_rupee,
                        ),
                        DashboardCard(
                          title: "Available Devices",
                          value: "7",
                          icon: Icons.check_circle,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      
    );
  }
}
