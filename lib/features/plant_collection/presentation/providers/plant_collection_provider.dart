import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_care_app/core/firebase/firebase_providers.dart';
import 'package:plant_care_app/features/plant_collection/domain/entities/plant_model.dart';

final plantCollectionProvider = StreamProvider<List<Plant>>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  
  if (user == null) {
    return Stream.value([]);
  }

  final firestore = ref.watch(firestoreProvider);
  
  return firestore
      .collection('users')
      .doc(user.uid)
      .collection('plants')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Plant(
            plantId: doc.id,
            name: data['name'] ?? 'Unknown Plant',
            imageUrl: data['imageUrl'] ?? '',
            description: data['description'] ?? '',
            timeToWater: data['timeToWater'] ?? 'Moderate',
            isToxic: data['isToxic'] ?? false,
            isIndoor: data['isIndoor'] ?? true,
            category: data['category'] ?? 'Indoor',
            origin: data['origin'] ?? 'Unknown',
            history: data['history'] ?? '',
            fertilizerInfo: data['fertilizerInfo'],
            healthStatus: data['healthStatus'],
            healthCheckHistory: (data['healthCheckHistory'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList(),
          );
        }).toList();
      });
});
