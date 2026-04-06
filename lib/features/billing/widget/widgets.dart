import 'package:flutter/material.dart';
import 'package:gaming_center/app.dart';
import 'package:gaming_center/core/constants/colors.dart';
import 'package:gaming_center/features/reports/provider/reports_provider.dart';
import 'package:gaming_center/features/settings/providers/settings_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

// ─────────────────────────────────────────────────────
// SLIM ICON-ONLY SIDEBAR (matching reference design)
// ─────────────────────────────────────────────────────
class SlimSidebar extends StatelessWidget {
  const SlimSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.sidebarActive,
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            child: Image.asset(
              'assets/images/IMG_8532.PNG',
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 28),

          // Nav icons
          _NavIcon(
            icon: Iconsax.home,
            activeIcon: Iconsax.home,
            section: AppSection.dashboard,
            tooltip: 'Dashboard',
          ),
          _NavIcon(
            icon: Iconsax.monitor,
            activeIcon: Iconsax.monitor,
            section: AppSection.devices,
            tooltip: 'Devices',
          ),
          _NavIcon(
            icon: Iconsax.play,
            activeIcon: Iconsax.play,
            section: AppSection.sessions,
            tooltip: 'Sessions',
          ),
          if (context.watch<NavigationProvider>().role == UserRole.admin) ...[
            _NavIcon(
              icon: Iconsax.chart,
              activeIcon: Iconsax.chart,
              section: AppSection.reports,
              tooltip: 'Reports',
            ),
            _NavIcon(
              icon: Iconsax.wallet,
              activeIcon: Iconsax.wallet,
              section: AppSection.expenses,
              tooltip: 'Expenses',
            ),
          ],

          const Spacer(),

          // Bottom icon
          if (context.watch<NavigationProvider>().role == UserRole.admin)
            _NavIcon(
              icon: Iconsax.setting,
              activeIcon: Iconsax.setting,
              section: AppSection.settings,
              tooltip: 'Settings',
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final AppSection section;
  final String tooltip;

  const _NavIcon({
    required this.icon,
    required this.activeIcon,
    required this.section,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final bool isActive = nav.current == section;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Tooltip(
        message: tooltip,
        preferBelow: false,
        child: InkWell(
          onTap: () => context.read<NavigationProvider>().setSection(section),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? AppColors.sidebarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? AppColors.sidebarActiveText
                  : AppColors.sidebarIcon,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// TOP BAR
// ─────────────────────────────────────────────────────
class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    final title = _getTitleForSection(nav.current);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Breadcrumb
          Row(
            children: [
              Icon(Iconsax.home,
                  size: 18, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                '›',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  String _getTitleForSection(AppSection section) {
    switch (section) {
      case AppSection.dashboard:
        return 'Dashboard';
      case AppSection.devices:
        return 'Devices';
      case AppSection.sessions:
        return 'Sessions';
      case AppSection.reports:
        return 'Reports';
      case AppSection.expenses:
        return 'Expenses';
      case AppSection.settings:
        return 'Settings';
    }
  }
}

// ─────────────────────────────────────────────────────
// REFERENCE STAT CARD (insightHub style)
// ─────────────────────────────────────────────────────
class ReferenceStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ReferenceStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(
                Icons.crop_free,
                color: AppColors.border,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(
                  icon,
                  color: AppColors.textPrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// ALERT BANNER
// ─────────────────────────────────────────────────────
class AlertBanner extends StatelessWidget {
  final String revenue;
  const AlertBanner({super.key, required this.revenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Dear Manager",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "We have observed a total revenue of $revenue generated today across all consoles.",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            onPressed: () {},
            child: const Text(
              "View Detail",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// UTILITY
// ─────────────────────────────────────────────────────
String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;

  if (h > 0 && m > 0) return '${h}h ${m}m';
  if (h > 0) return '${h}h';
  return '${m}m';
}

// ─────────────────────────────────────────────────────
// SCREEN TIME TABLE (Blue & White)
// ─────────────────────────────────────────────────────
class ScreenTimeChart extends StatefulWidget {
  const ScreenTimeChart({super.key});

  @override
  State<ScreenTimeChart> createState() => _ScreenTimeChartState();
}

class _ScreenTimeChartState extends State<ScreenTimeChart> {
  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    final Map<String, Duration> data =
        context.watch<ReportsProvider>().getTodayScreenTimePerConsole();

    final totalItems = data.length;
    final totalPages = totalItems == 0 ? 1 : (totalItems / _itemsPerPage).ceil();
    final paginatedData = data.entries.skip(_currentPage * _itemsPerPage).take(_itemsPerPage).toList();

    // Calculate sum of all durations
    final totalDuration = Duration(
      minutes: data.values.fold(0, (sum, d) => sum + d.inMinutes),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Screen Time Usage",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "Total: ${formatDuration(totalDuration)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: AppColors.primary.withValues(alpha: 0.05),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Console", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  Text("Total Time", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            if (data.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Iconsax.timer_1, color: AppColors.textMuted.withValues(alpha: 0.5), size: 32),
                      const SizedBox(height: 12),
                      const Text(
                        "No screen time recorded today",
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paginatedData.length,
                itemBuilder: (context, index) {
                  final entry = paginatedData[index];
                  final isEven = index % 2 == 0;
                  
                  return Container(
                    color: isEven ? Colors.white : AppColors.primary.withValues(alpha: 0.02),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Iconsax.game, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            formatDuration(entry.value),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (totalPages > 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                        icon: const Icon(Iconsax.arrow_left_2, size: 18),
                        label: const Text("Previous"),
                        style: TextButton.styleFrom(
                          disabledForegroundColor: AppColors.textMuted,
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                      Text(
                        "Page ${_currentPage + 1} of $totalPages",
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                        style: TextButton.styleFrom(
                          disabledForegroundColor: AppColors.textMuted,
                          foregroundColor: AppColors.primary,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text("Next"),
                            SizedBox(width: 4),
                            Icon(Iconsax.arrow_right_3, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// PAYMENTS TABLE (Blue & White)
// ─────────────────────────────────────────────────────
class PaymentsChart extends StatefulWidget {
  const PaymentsChart({super.key});

  @override
  State<PaymentsChart> createState() => _PaymentsChartState();
}

class _PaymentsChartState extends State<PaymentsChart> {
  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    final raw = context.watch<ReportsProvider>().getCurrentWeekDailyRevenue();
    final entries = raw.entries.toList();

    final totalItems = entries.length;
    final totalPages = totalItems == 0 ? 1 : (totalItems / _itemsPerPage).ceil();
    final paginatedEntries = entries.skip(_currentPage * _itemsPerPage).take(_itemsPerPage).toList();

    // Calculate total revenue
    final totalRevenue = entries.fold<double>(0, (sum, e) => sum + e.value);

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final currency = settings.settings.currencySymbol;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Weekly Payments Overview",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Total: $currency${totalRevenue.toInt()}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Day", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      Text("Revenue", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Iconsax.receipt_2_1, color: AppColors.textMuted.withValues(alpha: 0.5), size: 32),
                          const SizedBox(height: 12),
                          const Text(
                            "No payment data available",
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paginatedEntries.length,
                    itemBuilder: (context, index) {
                      final entry = paginatedEntries[index];
                      final isEven = index % 2 == 0;
                      
                      return Container(
                        color: isEven ? Colors.white : AppColors.primary.withValues(alpha: 0.02),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Iconsax.calendar_1, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('EEEE, MMM d').format(entry.key),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$currency${entry.value.toInt()}",
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (totalPages > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                            icon: const Icon(Iconsax.arrow_left_2, size: 18),
                            label: const Text("Previous"),
                            style: TextButton.styleFrom(
                              disabledForegroundColor: AppColors.textMuted,
                              foregroundColor: AppColors.primary,
                            ),
                          ),
                          Text(
                            "Page ${_currentPage + 1} of $totalPages",
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                          TextButton(
                            onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                            style: TextButton.styleFrom(
                              disabledForegroundColor: AppColors.textMuted,
                              foregroundColor: AppColors.primary,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text("Next"),
                                SizedBox(width: 4),
                                Icon(Iconsax.arrow_right_3, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────
// RECENT ACTIVITY WIDGET
// ─────────────────────────────────────────────────────
class ReferenceRecentActivityWidget extends StatefulWidget {
  const ReferenceRecentActivityWidget({super.key});

  @override
  State<ReferenceRecentActivityWidget> createState() => _ReferenceRecentActivityWidgetState();
}

class _ReferenceRecentActivityWidgetState extends State<ReferenceRecentActivityWidget> {
  int _currentPage = 0;
  static const int _itemsPerPage = 5;

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsProvider>();
    final List<dynamic> allSessions = List.from(reports.sessions);
    
    allSessions.sort((a, b) {
      if (a.endTime == null && b.endTime == null) return 0;
      if (a.endTime == null) return 1;
      if (b.endTime == null) return -1;
      return (b.endTime as int).compareTo(a.endTime as int);
    });

    final totalItems = allSessions.length;
    final totalPages = totalItems == 0 ? 1 : (totalItems / _itemsPerPage).ceil();
    final paginatedSessions = allSessions.skip(_currentPage * _itemsPerPage).take(_itemsPerPage).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.play_circle, color: AppColors.primary, size: 16),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "On Going Task",
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Iconsax.search_normal, color: AppColors.textSecondary, size: 18),
                  const SizedBox(width: 16),
                  Icon(Iconsax.setting_4, color: AppColors.textSecondary, size: 18),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Recent gaming sessions layout overview.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 24),
          if (allSessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  "No activity logged yet",
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paginatedSessions.length,
              separatorBuilder: (_, index) => Divider(
                color: AppColors.border.withValues(alpha: 0.3),
                height: 32,
              ),
              itemBuilder: (context, index) {
                final session = paginatedSessions[index];
                
                return Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.textPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          session.deviceName.substring(0, 1).toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.deviceName,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            session.game,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Status", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            session.isPaid ? "Paid" : "Pending",
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Duration", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(
                            formatDuration(Duration(seconds: session.duration)),
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) {
                        return Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Price", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(
                                "${settings.settings.currencySymbol}${session.price}",
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            if (totalPages > 1)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
                      icon: const Icon(Iconsax.arrow_left_2, size: 18),
                      label: const Text("Previous"),
                      style: TextButton.styleFrom(
                        disabledForegroundColor: AppColors.textMuted,
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                    Text(
                      "Page ${_currentPage + 1} of $totalPages",
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    TextButton(
                      onPressed: _currentPage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                      style: TextButton.styleFrom(
                        disabledForegroundColor: AppColors.textMuted,
                        foregroundColor: AppColors.primary,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text("Next"),
                          SizedBox(width: 4),
                          Icon(Iconsax.arrow_right_3, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
