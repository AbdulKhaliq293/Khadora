import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_care_app/core/firebase/firebase_providers.dart';
import 'package:plant_care_app/features/plant_collection/domain/entities/plant_model.dart';
import 'package:plant_care_app/features/plant_collection/data/services/gemini_service.dart';
import 'package:plant_care_app/core/services/notification_service.dart';

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

    // Get Gemini Recommendations
    Map<String, dynamic> careDetails = {};
    try {
      final geminiService = _ref.read(geminiServiceProvider);
      careDetails = await geminiService.getPlantCareDetails(
        plantName: plantData['name'] ?? 'Unknown Plant',
        description: plantData['description'] ?? '',
        isIndoor: plantData['isIndoor'] ?? true,
      );
    } catch (e) {
      print('Failed to get Gemini details: $e');
    }

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

    // Calculate schedules
    final int? waterFreq = careDetails['water_frequency_days'];
    final int? fertFreq = careDetails['fertilizer_frequency_days'];
    final DateTime now = DateTime.now();
    final DateTime? nextWater = waterFreq != null ? now.add(Duration(days: waterFreq)) : null;
    final DateTime? nextFert = fertFreq != null ? now.add(Duration(days: fertFreq)) : null;

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
      fertilizerInfo: careDetails['fertilizer_type'] ?? plantData['fertilizerInfo'],
      waterFrequencyDays: waterFreq,
      fertilizerFrequencyDays: fertFreq,
      fertilizerType: careDetails['fertilizer_type'],
      nextWaterDate: nextWater,
      nextFertilizeDate: nextFert,
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
      'waterFrequencyDays': plant.waterFrequencyDays,
      'fertilizerFrequencyDays': plant.fertilizerFrequencyDays,
      'fertilizerType': plant.fertilizerType,
      'nextWaterDate': plant.nextWaterDate,
      'nextFertilizeDate': plant.nextFertilizeDate,
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

    // Notifications
    try {
      final notificationService = _ref.read(notificationServiceProvider);
      final plantIdHash = plant.plantId.hashCode;

      // 1. Immediate Notification
      if (careDetails['short_care_summary'] != null) {
        await notificationService.showImmediateNotification(
          id: plantIdHash,
          title: 'Welcome ${plant.name}!',
          body: careDetails['short_care_summary'],
        );
      } else {
         await notificationService.showImmediateNotification(
          id: plantIdHash,
          title: 'Plant Added!',
          body: 'We are calculating the perfect care schedule for ${plant.name}.',
        );
      }

      // 2. Schedule Water Reminder
      if (nextWater != null) {
        await notificationService.scheduleNotification(
          id: plantIdHash + 1,
          title: 'Time to water ${plant.name}',
          body: 'Keep ${plant.name} hydrated! Check the soil moisture.',
          scheduledDate: nextWater,
        );
      }

      // 3. Schedule Fertilizer Reminder
      if (nextFert != null) {
        await notificationService.scheduleNotification(
          id: plantIdHash + 2,
          title: 'Fertilize ${plant.name}',
          body: 'Time to feed ${plant.name} with ${plant.fertilizerType ?? 'balanced fertilizer'}.',
          scheduledDate: nextFert,
        );
      }

    } catch (e) {
      print("Error scheduling notifications: $e");
    }
  }

  Future<void> scheduleBulkNotifications(Plant plant, int months) async {
    final notificationService = _ref.read(notificationServiceProvider);
    final int totalDays = months * 30;
    final DateTime now = DateTime.now();
    final int baseId = plant.plantId.hashCode;

    // Schedule Water
    if (plant.waterFrequencyDays != null && plant.waterFrequencyDays! > 0) {
      for (int i = plant.waterFrequencyDays!; i <= totalDays; i += plant.waterFrequencyDays!) {
        final DateTime scheduledDate = now.add(Duration(days: i));
        // Create a reasonably unique ID: base + i (offset) + 1 (type)
        // We use bitwise operations to keep it within 32-bit int range if needed, 
        // but Dart ints are 64-bit on VM. Flutter local notifications expects int32 on Android usually.
        // Let's keep it simple but try to avoid collisions.
        final int notificationId = (baseId + i * 100 + 1).abs(); 
        
        await notificationService.scheduleNotification(
          id: notificationId,
          title: 'Water ${plant.name}',
          body: 'Time to water your ${plant.name}!',
          scheduledDate: scheduledDate,
        );
      }
    }

    // Schedule Fertilizer
    if (plant.fertilizerFrequencyDays != null && plant.fertilizerFrequencyDays! > 0) {
      for (int i = plant.fertilizerFrequencyDays!; i <= totalDays; i += plant.fertilizerFrequencyDays!) {
        final DateTime scheduledDate = now.add(Duration(days: i));
        final int notificationId = (baseId + i * 100 + 2).abs();
        
        await notificationService.scheduleNotification(
          id: notificationId,
          title: 'Fertilize ${plant.name}',
          body: 'Time to fertilize your ${plant.name}!',
          scheduledDate: scheduledDate,
        );
      }
    }
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
