import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_care_app/features/plant_collection/domain/entities/maintenance_log.dart';

class MaintenanceRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  MaintenanceRepository(this._firestore, this.userId);

  Future<void> addLog(String plantId, MaintenanceLog log) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('plants')
        .doc(plantId)
        .collection('maintenance_logs')
        .doc(log.id)
        .set(log.toMap());
  }

  Stream<List<MaintenanceLog>> getLogs(String plantId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('plants')
        .doc(plantId)
        .collection('maintenance_logs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MaintenanceLog.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> deleteLog(String plantId, String logId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('plants')
        .doc(plantId)
        .collection('maintenance_logs')
        .doc(logId)
        .delete();
  }
}
