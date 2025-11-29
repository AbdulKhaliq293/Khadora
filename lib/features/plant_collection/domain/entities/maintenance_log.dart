import 'package:cloud_firestore/cloud_firestore.dart';

enum MaintenanceType {
  water,
  fertilizer,
}

class MaintenanceLog {
  final String id;
  final String plantId;
  final MaintenanceType type;
  final DateTime date;
  final double amount; // e.g., ml of water or grams of fertilizer
  final String? note;

  MaintenanceLog({
    required this.id,
    required this.plantId,
    required this.type,
    required this.date,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plantId': plantId,
      'type': type.name,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'note': note,
    };
  }

  factory MaintenanceLog.fromMap(Map<String, dynamic> map, String id) {
    return MaintenanceLog(
      id: id,
      plantId: map['plantId'] ?? '',
      type: MaintenanceType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MaintenanceType.water,
      ),
      date: (map['date'] as Timestamp).toDate(),
      amount: (map['amount'] as num).toDouble(),
      note: map['note'],
    );
  }
}
