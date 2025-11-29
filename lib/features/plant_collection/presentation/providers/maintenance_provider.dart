import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_care_app/core/firebase/firebase_providers.dart';
import 'package:plant_care_app/features/plant_collection/data/repositories/maintenance_repository.dart';
import 'package:plant_care_app/features/plant_collection/domain/entities/maintenance_log.dart';
import 'package:uuid/uuid.dart';

final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final user = ref.watch(firebaseAuthProvider).currentUser;
  
  if (user == null) {
    throw Exception('User not logged in');
  }
  
  return MaintenanceRepository(firestore, user.uid);
});

final maintenanceLogsProvider = StreamProvider.family<List<MaintenanceLog>, String>((ref, plantId) {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getLogs(plantId);
});

final maintenanceActionProvider = Provider((ref) {
  return MaintenanceAction(ref);
});

class MaintenanceAction {
  final Ref _ref;

  MaintenanceAction(this._ref);

  Future<void> addLog(String plantId, MaintenanceType type, double amount, {String? note}) async {
    final repository = _ref.read(maintenanceRepositoryProvider);
    final log = MaintenanceLog(
      id: const Uuid().v4(),
      plantId: plantId,
      type: type,
      date: DateTime.now(),
      amount: amount,
      note: note,
    );
    await repository.addLog(plantId, log);
  }
  
  Future<void> deleteLog(String plantId, String logId) async {
    final repository = _ref.read(maintenanceRepositoryProvider);
    await repository.deleteLog(plantId, logId);
  }
}
