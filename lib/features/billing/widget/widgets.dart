import 'package:flutter/material.dart';
import 'package:gaming_center/app.dart';
import 'package:gaming_center/core/constants/colors.dart';
import 'package:gaming_center/features/reports/provider/reports_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SideBar extends StatelessWidget {
  const SideBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 55),

          NavItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            section: AppSection.dashboard,
          ),
          NavItem(
            icon: Icons.devices,
            label: "Devices",
            section: AppSection.devices,
          ),
          NavItem(
            icon: Icons.monitor,
            label: "Sessions",
            section: AppSection.sessions,
          ),

          NavItem(
            icon: Icons.bar_chart,
            label: "Reports",
            section: AppSection.reports,
          ),
          // NavItem(
          //   icon: Icons.settings,
          //   label: "Settings",
          //   section: AppSection.settings,
          // ),
        ],
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            "BOOTCAMP ",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          CircleAvatar(
            backgroundColor: AppColors.surfaceLight,
            child: Icon(Icons.person, color: AppColors.icon),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppSection section;

  const NavItem({
    required this.icon,
    required this.label,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final bool isActive = nav.current == section;

    return InkWell(
      onTap: () {
        context.read<NavigationProvider>().setSection(section);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;

  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}

class ScreenTimeChart extends StatefulWidget {
  const ScreenTimeChart({super.key});

  @override
  State<ScreenTimeChart> createState() => _ScreenTimeChartState();
}

class _ScreenTimeChartState extends State<ScreenTimeChart> {
  String? selectedPeriod;

  @override
  Widget build(BuildContext context) {
    final Map<String, Duration> data = context
        .watch<ReportsProvider>()
        .getTodayScreenTimePerConsole();
    final maxMinutes = data.isEmpty
        ? 1
        : data.values.map((d) => d.inMinutes).reduce((a, b) => a > b ? a : b);

    final totalDuration = Duration(
      minutes: data.values.fold(0, (sum, d) => sum + d.inMinutes),
    );

    // final maxValue = data.isEmpty
    //     ? 1.0
    //     : data.values.every((v) => v == 0)
    //         ? 1.0
    //         : data.values.reduce((a, b) => a > b ? a : b);

    // final totalHours = data.values.fold(0.0, (a, b) => a + b);
    if (data.isEmpty || totalDuration.inMinutes == 0) {
      return _ChartContainer(
        title: "Screen Time",
        subtitle: "No usage today",
        trailing: const Text(
          "0m",
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const Center(
          child: Text(
            "No screen time recorded",
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return _ChartContainer(
      title: "Screen Time",
      subtitle: selectedPeriod != null
          ? "$selectedPeriod • ${formatDuration(data[selectedPeriod]!)}"
          : "Today’s console usage",

      trailing: Text(
        "${formatDuration(totalDuration)} total",
        style: TextStyle(
          color: selectedPeriod != null
              ? AppColors.primary.withOpacity(0.6)
              : AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.entries.map((e) {
          final minutes = e.value.inMinutes;

         

          final isHighest = minutes == maxMinutes;
          final isSelected = selectedPeriod == e.key;
        

const double minBarHeight = 40;
const double maxBarHeight = 200;

final safeHeight = maxMinutes == 0
    ? minBarHeight
    : minBarHeight +
        (minutes / maxMinutes) * (maxBarHeight - minBarHeight);


          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedPeriod = isSelected ? null : e.key;
                });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _AnimatedBar(
                        height: safeHeight,
                        isHighest: isHighest, // ✅ CORRECT
                        isSelected: isSelected,
                        child: Center(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: isSelected ? 1.0 : 0.85,
                            child: Text(
                              formatDuration(e.value),
                              style: TextStyle(
                                color: (isHighest || isSelected)
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: isSelected ? 10 : 9,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),
           AnimatedDefaultTextStyle(
  duration: const Duration(milliseconds: 200),
  style: TextStyle(
    color: isSelected
        ? AppColors.primary
        : AppColors.textMuted,
    fontSize: isSelected ? 12 : 13,
    fontWeight: FontWeight.w500,
  ),
  child: Text(
    e.key,
    maxLines: isSelected ? 2 : 1,
    overflow: isSelected
        ? TextOverflow.visible
        : TextOverflow.ellipsis,
    textAlign: TextAlign.center,
  ),
),

                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PaymentsChart extends StatefulWidget {
  const PaymentsChart({super.key});

  @override
  State<PaymentsChart> createState() => _PaymentsChartState();
}

class _PaymentsChartState extends State<PaymentsChart> {
  String? selectedDay;

  @override
  Widget build(BuildContext context) {
    final raw = context.watch<ReportsProvider>().getDailyRevenue();

    final data = {
      for (var e in raw.entries) DateFormat('EEE').format(e.key): e.value,
    };

    if (data.isEmpty) {
      return _ChartContainer(
        title: "Payments",
        subtitle: "No data yet",
        trailing: const Text(
          "₹0",
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        child: const Center(
          child: Text(
            "No payment data available",
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
      );
    }

    final maxValue = data.values.fold<int>(
      0,
      (max, v) => v.toInt() > max ? v.toInt() : max,
    );

    final total = data.values.fold<int>(0, (sum, v) => sum + v.toInt());

    return _ChartContainer(
      title: "Payments",
      subtitle: selectedDay != null
          ? "$selectedDay: ₹${data[selectedDay]}"
          : "This week",
      trailing: Text(
        "₹$total",
        style: TextStyle(
          color: selectedDay != null
              ? AppColors.primary.withOpacity(0.6)
              : AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      child: Column(
        children: data.entries.map((e) {
          final percentage = (e.value / maxValue * 100).toInt();
          final isHighest = e.value == maxValue;
          final isSelected = selectedDay == e.key;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDay = isSelected ? null : e.key;
              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.only(bottom: 16),
                transform: Matrix4.identity()
                  ..translate(isSelected ? 4.0 : 0.0, 0.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textMuted,
                          fontSize: isSelected ? 14 : 13,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        child: Text(e.key),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _AnimatedProgressBar(
                        progress: maxValue <= 0 ? 0 : e.value / maxValue,

                        isHighest: isHighest,
                        isSelected: isSelected,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 60,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: (isHighest || isSelected)
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: isSelected ? 14 : 13,
                        ),
                        child: Text("₹${e.value}", textAlign: TextAlign.right),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (isHighest || isSelected)
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: isSelected
                            ? Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                                width: 1,
                              )
                            : null,
                      ),
                      child: Text(
                        "$percentage%",
                        style: TextStyle(
                          color: (isHighest || isSelected)
                              ? AppColors.primary
                              : AppColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AnimatedBar extends StatefulWidget {
  final double height;
  final bool isHighest;
  final bool isSelected;
  final Widget child;

  const _AnimatedBar({
    required this.height,
    required this.isHighest,
    required this.isSelected,
    required this.child,
  });

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isHighest || widget.isSelected;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.height * _animation.value,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isActive
                  ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
                  : [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.primary.withOpacity(0.15),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: widget.isSelected
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 2,
                  )
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(
                        widget.isSelected ? 0.4 : 0.3,
                      ),
                      blurRadius: widget.isSelected ? 16 : 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final bool isHighest;
  final bool isSelected;

  const _AnimatedProgressBar({
    required this.progress,
    required this.isHighest,
    required this.isSelected,
  });

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.isHighest || widget.isSelected;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.isSelected ? 24 : 20,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(
                    widget.isSelected ? 12 : 10,
                  ),
                ),
              ),
              FractionallySizedBox(
                widthFactor: widget.progress * _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.85),
                            ]
                          : [
                              AppColors.primary.withOpacity(0.5),
                              AppColors.primary.withOpacity(0.3),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(
                      widget.isSelected ? 12 : 10,
                    ),
                    border: widget.isSelected
                        ? Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                            width: 2,
                          )
                        : null,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(
                                widget.isSelected ? 0.35 : 0.25,
                              ),
                              blurRadius: widget.isSelected ? 12 : 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChartContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget child;

  const _ChartContainer({
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        subtitle,
                        key: ValueKey(subtitle),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(height: 380, child: child),
        ],
      ),
    );
  }
}
