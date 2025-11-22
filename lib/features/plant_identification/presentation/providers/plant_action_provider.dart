import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_care_app/core/firebase/firebase_providers.dart';
import 'package:plant_care_app/features/plant_collection/domain/entities/plant_model.dart';

final plantActionProvider = Provider((ref) => PlantActionService(ref));

class PlantActionService {
  final Ref _ref;

  PlantActionService(this._ref);

  Future<void> addToCollection(Map<String, dynamic> plantData) async {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final firestore = _ref.read(firestoreProvider);
    
    // Map the identification data to Plant model structure
    // We generate a new ID
    final docRef = firestore.collection('users').doc(user.uid).collection('plants').doc();
    
    final plant = Plant(
      plantId: docRef.id,
      name: plantData['name'] ?? 'Unknown Plant',
      imageUrl: plantData['imageUrl'] ?? '',
      description: 'Identified as ${plantData['name']}. Family: ${plantData['type'] ?? 'Unknown'}.',
      timeToWater: plantData['watering'] ?? 'Moderate',
      isToxic: plantData['isToxic'] ?? false,
      isIndoor: true, // Default
      origin: plantData['origin'] ?? 'Unknown',
      history: 'Added via Identification on ${DateTime.now().toString()}',
      fertilizerInfo: plantData['fertilizerInfo'],
      healthStatus: 'Good',
      healthCheckHistory: [],
    );

    // Convert Plant object to Map for Firestore
    final data = {
      'plantId': plant.plantId,
      'name': plant.name,
      'imageUrl': plant.imageUrl,
      'description': plant.description,
      'timeToWater': plant.timeToWater,
      'isToxic': plant.isToxic,
      'isIndoor': plant.isIndoor,
      'origin': plant.origin,
      'history': plant.history,
      'fertilizerInfo': plant.fertilizerInfo,
      'healthStatus': plant.healthStatus,
      'healthCheckHistory': plant.healthCheckHistory,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data).timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Connection timed out. Please check your internet connection and ensure Firestore is enabled in your Firebase project.');
    });
  }
}
