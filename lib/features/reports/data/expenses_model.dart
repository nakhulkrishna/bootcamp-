import 'package:cloud_firestore/cloud_firestore.dart';




class ExpenseEntry {
  final DateTime date;
  final String category;
  final double amount;
  final String description;
  final String type; // 'income' or 'expense'

  ExpenseEntry({
    required this.date,
    required this.category,
    required this.amount,
    required this.description,
    required this.type,
  });

  factory ExpenseEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ExpenseEntry(
      date: (data['date'] as Timestamp).toDate(),
      category: data['category'],
      amount: (data['amount']).toDouble(),
      description: data['description'],
      type: (data['type'] as String?) ?? 'expense',
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

class GameProfit {
  final String gameName;
  final double revenue;

  GameProfit({
    required this.gameName,
    required this.revenue,
  });
}
