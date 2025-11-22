import 'dart:io';
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
    
    // Generate a new ID
    final docRef = firestore.collection('users').doc(user.uid).collection('plants').doc();
    
    String imageUrl = plantData['imageUrl'] ?? '';

    // Upload image to Firebase Storage if available
    if (plantData['imageFile'] != null && plantData['imageFile'] is File) {
      try {
        final file = plantData['imageFile'] as File;
        final storageRef = _ref.read(firebaseStorageProvider)
            .ref()
            .child('users/${user.uid}/plants/${docRef.id}.jpg');
        
        // Add timeout to upload
        await storageRef.putFile(file).timeout(const Duration(seconds: 30), onTimeout: () {
          throw Exception('Image upload timed out. Check your connection.');
        });
        
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        // Rethrow so the UI shows the error
        throw Exception('Failed to upload image: $e');
      }
    }

    final plant = Plant(
      plantId: docRef.id,
      name: plantData['name'] ?? 'Unknown Plant',
      imageUrl: imageUrl,
      description: plantData['description'] ?? 'Identified as ${plantData['name']}. Family: ${plantData['type'] ?? 'Unknown'}.',
      timeToWater: plantData['watering'] ?? 'Moderate',
      isToxic: plantData['isToxic'] ?? false,
      isIndoor: plantData['isIndoor'] ?? true,
      category: plantData['category'] ?? 'Indoor',
      origin: plantData['origin'] != null && plantData['origin'] is List 
          ? (plantData['origin'] as List).join(', ') 
          : (plantData['origin']?.toString() ?? 'Unknown'),
      history: 'Added via Identification on ${DateTime.now().toString()}',
      fertilizerInfo: plantData['fertilizerInfo'],
      healthStatus: 'Good',
      healthCheckHistory: [],
      sunlight: plantData['sunlight'],
      pruning: plantData['pruning'],
      hardiness: plantData['hardiness'],
      careInstructions: plantData['careInstructions'],
      type: plantData['type'],
      cycle: plantData['cycle'],
      growthRate: plantData['growthRate'],
      maintenance: plantData['maintenance'],
      poisonousToHumans: plantData['poisonousToHumans'],
      poisonousToPets: plantData['poisonousToPets'],
      droughtTolerant: plantData['droughtTolerant'],
      invasive: plantData['invasive'],
      apiId: plantData['apiId'],
      apiSource: plantData['apiSource'],
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
      'category': plant.category,
      'origin': plant.origin,
      'history': plant.history,
      'fertilizerInfo': plant.fertilizerInfo,
      'healthStatus': plant.healthStatus,
      'healthCheckHistory': plant.healthCheckHistory,
      'sunlight': plant.sunlight,
      'pruning': plant.pruning,
      'hardiness': plant.hardiness,
      'careInstructions': plant.careInstructions,
      'type': plant.type,
      'cycle': plant.cycle,
      'growthRate': plant.growthRate,
      'maintenance': plant.maintenance,
      'poisonousToHumans': plant.poisonousToHumans,
      'poisonousToPets': plant.poisonousToPets,
      'droughtTolerant': plant.droughtTolerant,
      'invasive': plant.invasive,
      'apiId': plant.apiId,
      'apiSource': plant.apiSource,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data).timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Connection timed out. Please check your internet connection and ensure Firestore is enabled in your Firebase project.');
    });
  }

  Future<void> deletePlant(String plantId, String? imageUrl) async {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final firestore = _ref.read(firestoreProvider);
    
    // Delete from Firestore
    await firestore.collection('users').doc(user.uid).collection('plants').doc(plantId).delete();

    // Delete image from Storage if it's a firebase storage URL
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.contains('firebasestorage.googleapis.com')) {
       try {
         final storage = _ref.read(firebaseStorageProvider);
         await storage.refFromURL(imageUrl).delete();
       } catch (e) {
         print('Error deleting image: $e');
       }
    }
  }
}
