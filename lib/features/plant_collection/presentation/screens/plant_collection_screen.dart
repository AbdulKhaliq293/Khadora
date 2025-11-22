import 'package:flutter/material.dart';

import 'package:plant_care_app/features/plant_collection/domain/entities/plant_model.dart';
import 'package:plant_care_app/features/plant_collection/presentation/screens/plant_collection_detail_screen.dart';

class PlantCollectionScreen extends StatefulWidget {
  const PlantCollectionScreen({super.key});

  @override
  State<PlantCollectionScreen> createState() => _PlantCollectionScreenState();
}

class _PlantCollectionScreenState extends State<PlantCollectionScreen> {
  // Placeholder for plant data - will be replaced with actual data later
  // Using placeholder image paths for now. These would need to be added to assets.
  final List<Plant> _plants = [
    Plant(
      plantId: '1',
      name: 'Parlor Palm Tree',
      imageUrl:
          'https://images.unsplash.com/photo-1541703044-7e33575f7c4c?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fHBhcmxvciUyMHBhbG0lMjB0cmVlfGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=900', // Placeholder image path
      description: 'A hardy and low-maintenance plant.',
      timeToWater: '2 days',
      isToxic: false,
      isIndoor: true,
      origin: 'West Africa',
      history: 'Used in traditional medicine.',
    ),
    Plant(
      plantId: '2',
      name: 'Coconut Tree',
      imageUrl:
          'https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8Q29jb251dCUyMFRyZWV8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=900', // Placeholder image path
      description: 'A popular and stylish houseplant.',
      timeToWater: '3 days',
      isToxic: true,
      isIndoor: true,
      origin: 'Mexico',
      history: 'A symbol of good luck.',
    ),
    Plant(
      plantId: '3',
      name: 'Green Blum Tree',
      imageUrl: 'assets/images/green_blum_tree.png', // Placeholder image path
      description: 'A forgiving and easy-to-care-for plant.',
      timeToWater: '1 day',
      isToxic: true,
      isIndoor: true,
      origin: 'Southeast Asia',
      history: 'Known for its air-purifying qualities.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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

            // Placeholder for search/filter if needed, similar to HomeScreen
            // For now, focusing on the collection list itself.
            Expanded(
              child: _plants.isEmpty
                  ? Center(
                      child: Text(
                        'Your plant collection is empty.',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _plants.length,
                      itemBuilder: (context, index) {
                        final plant = _plants[index];
                        return _buildPlantCard(context, plant);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Reusing the plant card widget from HomeScreen for consistency
  Widget _buildPlantCard(BuildContext context, Plant plant) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      color: Theme.of(context).cardColor, // Use theme card color
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Plant Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                // Changed to Image.network
                plant.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  // Fallback for missing images
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
            // Plant Details
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
                    plant.isIndoor ? 'Indoor' : 'Outdoor', // Displaying type
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
                      // Add light status if available in Plant model and desired
                      // const SizedBox(width: 16),
                      // Icon(Icons.sunny, color: Theme.of(context).primaryColor, size: 18),
                      // const SizedBox(width: 4),
                      // Text('${plant.light}%', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)), // Assuming light is available
                    ],
                  ),
                ],
              ),
            ),
            // Arrow Icon for navigation
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
