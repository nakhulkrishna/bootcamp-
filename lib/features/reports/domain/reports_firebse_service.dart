import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gaming_center/features/device_management/data/model.dart';
import 'package:gaming_center/features/reports/data/expenses_model.dart';
import 'package:gaming_center/features/reports/presentation/reports_screen.dart' hide ExpenseEntry;


class ReportsFirebaseService {
  static final _db = FirebaseFirestore.instance;

  /// ✅ FETCH COMPLETED PAID SESSIONS (REVENUE)
static Future<List<SessionModel>> fetchSessions({
  required DateTime from,
  required DateTime to,
}) async {
  debugPrint('🔥 Fetching sessions from Firestore');

  final snapshot = await _db
      .collection('sessions')
      .where('isPaid', isEqualTo: true)
      .where('endTime', isGreaterThanOrEqualTo: from.millisecondsSinceEpoch)
      .where('endTime', isLessThanOrEqualTo: to.millisecondsSinceEpoch)
      .get();

  debugPrint('📄 Session docs: ${snapshot.docs.length}');

  return snapshot.docs.map((doc) {
    final model = SessionModel.fromFirestore(doc);
    debugPrint(
        '➡️ Session | price: ${model.price}, endTime: ${model.endTime}');
    return model;
  }).toList();
}


  /// ✅ FETCH EXPENSES
  static Future<List<ExpenseEntry>> fetchExpenses({
    required DateTime from,
    required DateTime to,
  }) async {
    final snapshot = await _db
        .collection('expenses')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(to))
        .get();

    return snapshot.docs.map(ExpenseEntry.fromFirestore).toList();
  }

  static Future<void> addExpense({
  required String category,
  required double amount,
  required String description,
}) async {
  await _db.collection('expenses').add({
    'category': category,
    'amount': amount,
    'description': description,
    'date': Timestamp.now(),
  });
}

}
