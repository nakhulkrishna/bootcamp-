import 'dart:async';
import 'package:flutter/material.dart';
import '../data/expense_model.dart';
import '../domain/firebase_service_expenses.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirebaseServiceExpenses _service = FirebaseServiceExpenses();
  List<ExpenseModel> _expenses = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  List<ExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;

  ExpenseProvider() {
    _listenToExpenses();
  }

  void _listenToExpenses() {
    _subscription?.cancel();
    _subscription = _service.getExpenses().listen((data) {
      _expenses = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// 🔹 Totals logic
  double get totalIncome => _expenses
      .where((e) => e.type == ExpenseType.income)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalExpense => _expenses
      .where((e) => e.type == ExpenseType.expense)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get netProfit => totalIncome - totalExpense;

  /// 🔹 CRUD wrapped
  Future<void> addExpense(ExpenseModel expense) async {
    await _service.addExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _service.deleteExpense(id);
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _service.updateExpense(expense);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
