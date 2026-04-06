import 'package:flutter/material.dart';
import 'package:gaming_center/features/device_management/data/model.dart';
import 'package:gaming_center/features/reports/data/expenses_model.dart';
import 'package:gaming_center/features/reports/domain/reports_firebse_service.dart';

class ReportsProvider extends ChangeNotifier {
  List<SessionModel> sessions = [];
  List<ExpenseEntry> expenses = [];

  bool loading = false;

  DateTime? _from;
  DateTime? _to;

  /* ───────────────────────── TOTALS ───────────────────────── */

  /// 💰 TOTAL REVENUE (PAID ONLY)
  double get totalRevenue {
    final sessionRevenue = sessions
        .where((s) => s.isPaid)
        .fold(0.0, (sum, s) => sum + s.price.toDouble());

    final otherIncome = expenses
        .where((e) => e.type == 'income')
        .fold(0.0, (sum, e) => sum + e.amount);

    return sessionRevenue + otherIncome;
  }

  /// 💸 TOTAL EXPENSE
  double get totalExpenses {
    return expenses
        .where((e) => e.type != 'income')
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// ✅ NET PROFIT
  double get netProfit => totalRevenue - totalExpenses;

  /* ───────────────────────── LOAD DATA ───────────────────────── */

  Future<void> loadReports({
    required DateTime from,
    required DateTime to,
  }) async {
    loading = true;
    notifyListeners();

    _from = from;
    _to = to;

    sessions =
        await ReportsFirebaseService.fetchSessions(from: from, to: to);
    expenses =
        await ReportsFirebaseService.fetchExpenses(from: from, to: to);

    loading = false;
    notifyListeners();
  }

  /* ───────────────────────── EXPENSE ───────────────────────── */

  Future<void> addExpense({
    required String category,
    required double amount,
    required String description,
  }) async {
    final now = DateTime.now();

    await ReportsFirebaseService.addExpense(
      category: category,
      amount: amount,
      description: description,
    );

    if (_isWithinRange(now)) {
      expenses.add(
        ExpenseEntry(
          date: now,
          category: category,
          amount: amount,
          description: description,
          type: 'expense',
        ),
      );
    }

    notifyListeners();
  }

  /* ───────────────────────── CONSOLE REVENUE ───────────────────────── */

  List<ConsoleProfit> getConsoleRevenue() {
    final Map<String, ConsoleProfit> map = {};

    for (final s in sessions) {
      if (!s.isPaid) continue;

      final sessionDate =
          DateTime.fromMillisecondsSinceEpoch(s.startTime);

      if (!_isWithinRange(sessionDate)) continue;

      map.update(
        s.deviceId,
        (existing) => ConsoleProfit(
          deviceId: existing.deviceId,
          deviceName: existing.deviceName,
          revenue: existing.revenue + s.price.toDouble(),
        ),
        ifAbsent: () => ConsoleProfit(
          deviceId: s.deviceId,
          deviceName: s.deviceName,
          revenue: s.price.toDouble(),
        ),
      );
    }

    return map.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
  }

  /* ───────────────────────── GAME REVENUE ───────────────────────── */

  List<GameProfit> getGameRevenue() {
    final Map<String, GameProfit> map = {};

    for (final s in sessions) {
      if (!s.isPaid) continue;

      map.update(
        s.game,
        (existing) => GameProfit(
          gameName: existing.gameName,
          revenue: existing.revenue + s.price.toDouble(),
        ),
        ifAbsent: () => GameProfit(
          gameName: s.game,
          revenue: s.price.toDouble(),
        ),
      );
    }

    return map.values.toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));
  }


  /* ───────────────────────── TODAY SCREEN TIME ───────────────────────── */

  Map<String, Duration> getTodayScreenTimePerConsole() {
    final Map<String, Duration> result = {};

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    for (final s in sessions) {
      if (!s.isPaid || s.endTime == null) continue;

      final sessionEnd =
          DateTime.fromMillisecondsSinceEpoch(s.endTime!);

      if (sessionEnd.isBefore(startOfDay) || !sessionEnd.isBefore(endOfDay)) {
        continue;
      }

      final sessionStart =
          DateTime.fromMillisecondsSinceEpoch(s.startTime);

      final duration = sessionEnd.difference(sessionStart);
      if (duration.inSeconds <= 0) continue;

      result[s.deviceName] =
          (result[s.deviceName] ?? Duration.zero) + duration;
    }

    return result;
  }

  /* ───────────────────────── CURRENT MONTH EXPENSES ───────────────────────── */

  List<ExpenseEntry> get currentMonthExpenses {
    final now = DateTime.now();

    return expenses
        .where((e) =>
            e.type != 'income' &&
            e.date.year == now.year &&
            e.date.month == now.month)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /* ───────────────────────── DAILY REVENUE ───────────────────────── */

  Map<DateTime, double> getDailyRevenue() {
    final Map<DateTime, double> revenueByDate = {};

    for (final s in sessions.where((e) => e.isPaid && e.endTime != null)) {
      final d =
          DateTime.fromMillisecondsSinceEpoch(s.endTime!);
      final dateOnly = DateTime(d.year, d.month, d.day);

      revenueByDate.update(
        dateOnly,
        (value) => value + s.price.toDouble(),
        ifAbsent: () => s.price.toDouble(),
      );
    }

    for (final e in expenses.where((e) => e.type == 'income')) {
      final dateOnly = DateTime(e.date.year, e.date.month, e.date.day);
      revenueByDate.update(
        dateOnly,
        (value) => value + e.amount,
        ifAbsent: () => e.amount,
      );
    }

    final sortedKeys = revenueByDate.keys.toList()..sort();

    return {
      for (final k in sortedKeys) k: revenueByDate[k]!,
    };
  }

  /* ───────────────────────── WEEKLY REVENUE ───────────────────────── */

  DateTime startOfWeek(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - 1));
  }

  Map<DateTime, double> getCurrentWeekDailyRevenue() {
    final Map<DateTime, double> revenueByDate = {};

    final now = DateTime.now();
    final weekStart = startOfWeek(now);
    final weekEnd = weekStart.add(const Duration(days: 7));

    for (final s in sessions.where((e) => e.isPaid && e.endTime != null)) {
      final d =
          DateTime.fromMillisecondsSinceEpoch(s.endTime!);

      if (d.isBefore(weekStart) || !d.isBefore(weekEnd)) continue;

      final dateOnly = DateTime(d.year, d.month, d.day);

      revenueByDate.update(
        dateOnly,
        (value) => value + s.price.toDouble(),
        ifAbsent: () => s.price.toDouble(),
      );
    }

    final sortedKeys = revenueByDate.keys.toList()..sort();

    return {
      for (final k in sortedKeys) k: revenueByDate[k]!,
    };
  }

  /* ───────────────────────── TODAY STATS ───────────────────────── */

  double get todayRevenue {
    final today = DateTime.now();

    final sessionRevenue = sessions
        .where((s) {
          if (!s.isPaid || s.endTime == null) return false;
          final d =
              DateTime.fromMillisecondsSinceEpoch(s.endTime!);
          return d.year == today.year &&
              d.month == today.month &&
              d.day == today.day;
        })
        .fold(0.0, (sum, s) => sum + s.price.toDouble());
    final incomeToday = expenses
        .where((e) =>
            e.type == 'income' &&
            e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day)
        .fold(0.0, (sum, e) => sum + e.amount);

    return sessionRevenue + incomeToday;
  }

  // Removed activeSessions getter, use SessionProvider instead.

  int get completedSessionsToday {
    final today = DateTime.now();

    return sessions.where((s) {
      if (s.status != SessionStatus.completed || s.endTime == null) return false;
      final d =
          DateTime.fromMillisecondsSinceEpoch(s.endTime!);
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day;
    }).length;
  }

  /* ───────────────────────── MONTHLY SUMMARY (YEAR SAFE) ───────────────────────── */

/* ───────────────────────── MONTHLY SUMMARY ───────────────────────── */

Map<int, Map<String, double>> getMonthlySummary() {
  final Map<int, double> revenue = {};
  final Map<int, double> expense = {};

  // Process sessions for revenue
  for (final s in sessions.where((e) => e.isPaid && e.endTime != null)) {
    final d = DateTime.fromMillisecondsSinceEpoch(s.endTime!);
    final month = d.month;

    revenue[month] = (revenue[month] ?? 0) + s.price.toDouble();
  }

  // Process expenses
  for (final e in expenses) {
    final month = e.date.month;
    if (e.type == 'income') {
      revenue[month] = (revenue[month] ?? 0) + e.amount;
    } else {
      expense[month] = (expense[month] ?? 0) + e.amount;
    }
  }

  // Return all 12 months with default values
  return {
    for (int month = 1; month <= 12; month++)
      month: {
        'revenue': revenue[month] ?? 0,
        'expense': expense[month] ?? 0,
      }
  };
}
  /* ───────────────────────── HELPERS ───────────────────────── */

  bool _isWithinRange(DateTime date) {
    if (_from == null || _to == null) return true;
    return !date.isBefore(_from!) && !date.isAfter(_to!);
  }
}
