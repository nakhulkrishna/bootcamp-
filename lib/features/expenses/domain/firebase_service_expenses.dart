import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gaming_center/core/config/environment.dart';
import '../data/expense_model.dart';

class FirebaseServiceExpenses {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔹 Add Expense or Income
  Future<void> addExpense(ExpenseModel expense) async {
    await _db.collection(EnvironmentConfig.collection('expenses')).add(expense.toMap());
  }

  /// 🔹 Get all expenses (Real-time)
  Stream<List<ExpenseModel>> getExpenses() {
    return _db
        .collection(EnvironmentConfig.collection('expenses'))
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseModel.fromFirestore(doc))
            .toList());
  }

  /// 🔹 Delete Expense
  Future<void> deleteExpense(String expenseId) async {
    await _db.collection(EnvironmentConfig.collection('expenses')).doc(expenseId).delete();
  }

  /// 🔹 Update Expense
  Future<void> updateExpense(ExpenseModel expense) async {
    await _db.collection(EnvironmentConfig.collection('expenses')).doc(expense.id).update(expense.toMap());
  }
}
