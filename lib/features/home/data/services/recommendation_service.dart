import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_care_app/core/firebase/firebase_providers.dart';
import 'package:plant_care_app/features/home/data/recommendation_data.dart';
import 'package:plant_care_app/features/home/domain/entities/recommendation_plant.dart';

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService(ref.watch(firestoreProvider));
});

final recommendationsProvider = FutureProvider<List<RecommendationPlant>>((ref) async {
  final service = ref.watch(recommendationServiceProvider);
  await service.seedDataIfNeeded();
  return service.getRecommendations();
});

class RecommendationService {
  final FirebaseFirestore _firestore;
  static const String collectionName = 'recommendations';

  RecommendationService(this._firestore);

  Future<void> seedDataIfNeeded() async {
    try {
      // Check if we need to seed or update data
      // For development/testing, we can force update to ensure latest data
      print('Syncing recommendation data...');
      final batch = _firestore.batch();
      
      for (final plant in initialRecommendationPlants) {
        final docRef = _firestore.collection(collectionName).doc(plant.id);
        // Use set with merge: true to update existing docs or create new ones
        batch.set(docRef, plant.toMap(), SetOptions(merge: true));
      }
      
      await batch.commit();
      print('Syncing complete.');
    } catch (e) {
      print('Error syncing data: $e');
    }
  }

  Future<List<RecommendationPlant>> getRecommendations() async {
    try {
      final snapshot = await _firestore.collection(collectionName).get();
      
      if (snapshot.docs.isEmpty) return [];
      
      final allDocs = snapshot.docs.toList();
      allDocs.shuffle();
      
      return allDocs.map((doc) => RecommendationPlant.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error fetching recommendations: $e');
      return [];
    }
  }
}
