import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String id;
  final String name;
  final String category; // 'Standard', 'VR', 'Car Racing'

  GameModel({
    required this.id,
    required this.name,
    this.category = 'Standard',
  });

  /// 🔹 Firestore → Model
  factory GameModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    // Handle migration from legacy 'isVR' boolean
    String category = data['category'] ?? 'Standard';
    if(category == 'Normal') category = 'Standard';
    if (data.containsKey('isVR') && data['isVR'] == true) {
      category = 'VR';
    }

    return GameModel(
      id: doc.id,
      name: data['name'] ?? '',
      category: category,
    );
  }

  /// 🔹 Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
