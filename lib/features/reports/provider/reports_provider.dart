import 'package:flutter/material.dart';
import 'package:gaming_center/features/device_management/data/model.dart';
import 'package:gaming_center/features/reports/data/expenses_model.dart';
import 'package:gaming_center/features/reports/domain/reports_firebse_service.dart';

class ReportsProvider extends ChangeNotifier {
  List<SessionModel> sessions = [];
  List<ExpenseEntry> expenses = [];

  bool loading = false;

  /// 💰 TOTAL REVENUE
  double get totalRevenue =>
      sessions.fold(0.0, (sum, s) => sum + s.price.toDouble());

  /// 💸 TOTAL EXPENSE
  double get totalExpenses => expenses.fold(0.0, (sum, e) => sum + e.amount);

  /// ✅ NET PROFIT
  double get netProfit => totalRevenue - totalExpenses;

  /// ✅ LOAD REPORT DATA
Future<void> loadReports({
  required DateTime from,
  required DateTime to,
}) async {
  loading = true;
  notifyListeners();

  debugPrint('📊 Loading reports...');
  debugPrint('FROM: $from');
  debugPrint('TO  : $to');

  sessions = await ReportsFirebaseService.fetchSessions(
    from: from,
    to: to,
  );

  expenses = await ReportsFirebaseService.fetchExpenses(
    from: from,
    to: to,
  );

  debugPrint('✅ Sessions loaded: ${sessions.length}');
  debugPrint('✅ Expenses loaded: ${expenses.length}');

  if (sessions.isNotEmpty) {
    debugPrint('🧾 First session price: ${sessions.first.price}');
  }

  loading = false;
  notifyListeners();
}
Future<void> addExpense({
  required String category,
  required double amount,
  required String description,
}) async {
  debugPrint('➕ Adding expense: $category ₹$amount');

  await ReportsFirebaseService.addExpense(
    category: category,
    amount: amount,
    description: description,
  );

  // ✅ Add locally for instant UI update
  expenses.add(
    ExpenseEntry(
      date: DateTime.now(),
      category: category,
      amount: amount,
      description: description,
    ),
  );

  notifyListeners();
}

List<ConsoleProfit> getConsoleRevenue() {
  final Map<String, ConsoleProfit> map = {};

  for (final s in sessions) {
    if (!map.containsKey(s.deviceId)) {
      map[s.deviceId] = ConsoleProfit(
        deviceId: s.deviceId,
        deviceName: s.deviceName,
        revenue: 0,
      );
    }

    map[s.deviceId] = ConsoleProfit(
      deviceId: s.deviceId,
      deviceName: s.deviceName,
      revenue: map[s.deviceId]!.revenue + s.price,
    );
  }

  return map.values.toList()
    ..sort((a, b) => b.revenue.compareTo(a.revenue));
}

Map<String, Duration> getTodayScreenTimePerConsole() {
  final Map<String, Duration> result = {};

  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));

  for (final s in sessions) {
    // ✅ completed sessions only
    if (!s.isPaid || s.endTime == null) continue;

    final sessionEnd =
        DateTime.fromMillisecondsSinceEpoch(s.endTime!);

    // ✅ only TODAY sessions
    if (sessionEnd.isBefore(startOfDay) ||
        sessionEnd.isAfter(endOfDay)) continue;

    // ✅ calculate duration safely
    final sessionStart =
        DateTime.fromMillisecondsSinceEpoch(s.startTime);

    final duration = sessionEnd.difference(sessionStart);

    if (duration.inSeconds <= 0) continue;

    result[s.deviceName] =
        (result[s.deviceName] ?? Duration.zero) + duration;
  }

  return result;
}
Map<DateTime, double> getDailyRevenue() {
  final Map<DateTime, double> revenueByDate = {};

  for (final s in sessions.where((e) => e.isPaid)) {
    final d = DateTime.fromMillisecondsSinceEpoch(s.startTime);
    final dateOnly = DateTime(d.year, d.month, d.day);

    revenueByDate[dateOnly] =
        (revenueByDate[dateOnly] ?? 0) + s.price;
  }

  return revenueByDate;
}
double get todayRevenue {
  final today = DateTime.now();

  return sessions
      .where((s) {
        if (!s.isPaid) return false;

        final d =
            DateTime.fromMillisecondsSinceEpoch(s.startTime);

        return d.year == today.year &&
            d.month == today.month &&
            d.day == today.day;
      })
      .fold(0.0, (sum, s) => sum + s.price);
}
int get activeSessions {
  return sessions
      .where((s) => s.status == SessionStatus.running)
      .length;
}
int get completedSessionsToday {
  final today = DateTime.now();

  return sessions.where((s) {
    if (s.status != SessionStatus.completed) return false;

    final d =
        DateTime.fromMillisecondsSinceEpoch(s.startTime);

    return d.year == today.year &&
        d.month == today.month &&
        d.day == today.day;
  }).length;
}

  /// ✅ MONTHLY DATA FOR BAR CHART
  Map<int, Map<String, double>> getMonthlySummary() {
    final Map<int, double> revenue = {};
    final Map<int, double> expense = {};

    for (final s in sessions) {
      if (s.endTime == null) continue;

      final month = DateTime.fromMillisecondsSinceEpoch(s.endTime!).month;

      revenue[month] = (revenue[month] ?? 0) + s.price;
    }

    for (final e in expenses) {
      expense[e.date.month] = (expense[e.date.month] ?? 0) + e.amount;
    }

    return {
      for (int m = 1; m <= 12; m++)
        m: {'revenue': revenue[m] ?? 0, 'expense': expense[m] ?? 0},
    };
  }
}
