import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpenseType { income, expense }

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String description;
  final ExpenseType type;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    required this.type,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ExpenseModel(
      id: doc.id,
      title: data['title'] ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? 'General',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'] ?? '',
      type: data['type'] == 'income' ? ExpenseType.income : ExpenseType.expense,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'description': description,
      'type': type == ExpenseType.income ? 'income' : 'expense',
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    ExpenseType? type,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      type: type ?? this.type,
    );
  }
}
