import 'package:cloud_firestore/cloud_firestore.dart';




class ExpenseEntry {
  final DateTime date;
  final String category;
  final double amount;
  final String description;

  ExpenseEntry({
    required this.date,
    required this.category,
    required this.amount,
    required this.description,
  });

  factory ExpenseEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ExpenseEntry(
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'],
      amount: (data['amount']).toDouble(),
      description: data['description'],
    );
  }
}

class ConsoleProfit {
  final String deviceId;
  final String deviceName;
  final double revenue;

  ConsoleProfit({
    required this.deviceId,
    required this.deviceName,
    required this.revenue,
  });
}
