import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_care_app/core/firebase/firebase_providers.dart';
import 'package:plant_care_app/features/plant_collection/domain/entities/plant_model.dart';
import 'package:plant_care_app/features/plant_collection/presentation/screens/plant_collection_detail_screen.dart';

class PlantCollectionScreen extends ConsumerWidget {
  const PlantCollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final firestore = ref.watch(firestoreProvider);

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'Please log in to view your collection.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppBar(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              iconTheme: Theme.of(context).appBarTheme.iconTheme,
              title: Text(
                'My Collection',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              centerTitle: true,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('plants')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'Your plant collection is empty.',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    );
                  }

                  final plants = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Plant(
                      plantId: doc.id,
                      name: data['name'] ?? 'Unknown',
                      imageUrl: data['imageUrl'] ?? '',
                      description: data['description'] ?? '',
                      timeToWater: data['timeToWater'] ?? '',
                      isToxic: data['isToxic'] ?? false,
                      isIndoor: data['isIndoor'] ?? true,
                      origin: data['origin'] ?? '',
                      history: data['history'] ?? '',
                      fertilizerInfo: data['fertilizerInfo'],
                      healthStatus: data['healthStatus'],
                      healthCheckHistory: (data['healthCheckHistory'] as List?)?.map((e) => e.toString()).toList(),
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      final plant = plants[index];
                      return _buildPlantCard(context, plant);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantCard(BuildContext context, Plant plant) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                plant.imageUrl.isNotEmpty ? plant.imageUrl : 'https://images.unsplash.com/photo-1541703044-7e33575f7c4c?q=60&w=200', // Fallback
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Theme.of(context).hintColor.withOpacity(0.3),
                  child: Icon(
                    Icons.broken_image,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plant.isIndoor ? 'Indoor' : 'Outdoor',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        color: Theme.of(context).primaryColor,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        plant.timeToWater,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        PlantCollectionDetailScreen(plant: plant),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
