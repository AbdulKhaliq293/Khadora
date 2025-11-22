import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:plant_care_app/core/theme/colors.dart'; // Import colors
import 'package:plant_care_app/core/theme/theme_provider.dart'; // Import ThemeProvider
import 'package:plant_care_app/features/plant_collection/domain/entities/plant_model.dart';
import 'package:plant_care_app/features/plant_collection/presentation/screens/plant_collection_detail_screen.dart';
import 'package:plant_care_app/features/plant_identification/presentation/screens/add_plant_screen.dart'; // Import AddPlantScreen

class HomeScreen extends ConsumerStatefulWidget {
  // Change to ConsumerStatefulWidget
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState(); // Change to ConsumerState
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Change to ConsumerState
  String _selectedCategory = 'All'; // State for selected category

  // Placeholder for plant data - will be replaced with actual data later
  // Using network image URLs now as per user feedback.
  final List<Map<String, dynamic>> _plants = [
    {
      'name': 'Parlor Palm Tree',
      'type': 'Indoor',
      'water': 70,
      'light': 65,
      'imageUrl':
          'https://images.unsplash.com/photo-1588302740742-1accfa27b0f6?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8bW9uc3RybyUyMHBsYW50fGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=900', // Network image URL
      'origin': 'Mexico',
      'watering': 'Frequent',
      'sunlight': 'Part shade',
      'maintenance': 'Low',
      'care_level': 'Medium',
      'isToxic': false,
    },
    {
      'name': 'Coconut Tree',
      'type': 'Outdoor',
      'water': 50,
      'light': 80,
      'imageUrl':
          'https://images.unsplash.com/photo-1588302740742-1accfa27b0f6?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8bW9uc3RybyUyMHBsYW50fGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=900', // Network image URL (using same for placeholder)
      'origin': 'Southeast Asia',
      'watering': 'Moderate',
      'sunlight': 'Full sun',
      'maintenance': 'Medium',
      'care_level': 'Medium',
      'isToxic': true,
    },
    {
      'name': 'Green Blum Tree',
      'type': 'Garden',
      'water': 60,
      'light': 70,
      'imageUrl':
          'https://images.unsplash.com/photo-1723788217248-508d1836e153?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fHBvdGhvc3BsYW50fGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=900', // Network image URL
      'origin': 'South America',
      'watering': 'Regular',
      'sunlight': 'Full sun',
      'maintenance': 'Low',
      'care_level': 'Easy',
      'isToxic': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter plants based on selected category
    List<Map<String, dynamic>> filteredPlants = _plants.where((plant) {
      if (_selectedCategory == 'All') {
        return true;
      }
      return plant['type'] == _selectedCategory;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Logo/Name and Theme Switch
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .spaceBetween, // Align items to start and end
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_florist,
                        color: Theme.of(context).primaryColor,
                        size: 40,
                      ), // Use theme primary color
                      SizedBox(width: 8),
                      Text(
                        'Khodra', // App name as requested
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.color, // Use theme color
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value:
                        ref.watch(themeProvider) ==
                        ThemeMode.dark, // Watch theme mode
                    onChanged: (isDark) {
                      ref
                          .read(themeProvider.notifier)
                          .toggleTheme(isDark); // Toggle theme
                    },
                    activeColor: Theme.of(
                      context,
                    ).primaryColor, // Use theme primary color
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Welcome!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).hintColor, // Use theme hint color
                ),
              ),
              const SizedBox(height: 48),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search here...',
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor.withOpacity(0.7),
                  ), // Use theme hint color
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).hintColor,
                  ), // Use theme hint color
                  suffixIcon: Icon(
                    Icons.filter_list,
                    color: Theme.of(context).hintColor,
                  ), // Use theme hint color
                  filled: true,
                  fillColor: Theme.of(context)
                      .inputDecorationTheme
                      .fillColor, // Use theme input decoration fill color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ), // Use theme text color
              ),
              const SizedBox(height: 20),

              // Category Filters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('All'),
                    _buildCategoryChip('Indoor'),
                    _buildCategoryChip('Outdoor'),
                    _buildCategoryChip('Garden'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Plant List
              Expanded(
                child: filteredPlants.isEmpty
                    ? Center(
                        child: Text(
                          'No plants found in this category.',
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                          ), // Use theme hint color
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredPlants.length,
                        itemBuilder: (context, index) {
                          final plant = filteredPlants[index];
                          return _buildPlantCard(
                            context,
                            plant['name'],
                            plant['type'],
                            plant['water'],
                            plant['light'],
                            plant['imageUrl'],
                            plant['origin'], // Pass origin
                            plant['watering'], // Pass watering
                            plant['sunlight'], // Pass sunlight
                            plant['maintenance'], // Pass maintenance
                            plant['care_level'], // Pass careLevel
                            plant['isToxic'], // Pass isToxic
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // Floating Action Button for scanning/adding a plant
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  const AddPlantScreen(), // Navigate to the scanning screen
            ),
          );
        },
        backgroundColor: Theme.of(
          context,
        ).primaryColor, // Use theme primary color
        child: Icon(
          Icons.camera_alt,
          color: Theme.of(context).iconTheme.color,
        ), // Use theme icon color
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ChoiceChip(
        label: Text(
          category,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(
                    context,
                  ).textTheme.bodyLarge?.color, // Use theme colors
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: Theme.of(
          context,
        ).primaryColor, // Use theme primary color
        backgroundColor: Theme.of(context).cardColor, // Use theme card color
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  Widget _buildPlantCard(
    BuildContext context,
    String? name, // Made nullable
    String? type, // Made nullable
    int? water, // Made nullable
    int? light, // Made nullable
    String? imageUrl, // Made nullable
    String? origin, // Added origin, made nullable
    String? watering, // Added watering, made nullable
    String? sunlight, // Added sunlight, made nullable
    String? maintenance, // Added maintenance, made nullable
    String? careLevel, // Added careLevel, made nullable
    bool? isToxic, // Added isToxic, made nullable
  ) {
    final cardHeight = MediaQuery.of(context).size.height * 0.28;

    return GestureDetector(
      onTap: () {
        // Navigate to PlantCollectionDetailScreen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlantCollectionDetailScreen(
              plant: Plant(
                plantId: name ?? 'unknown_id',
                name: name ?? 'Unknown Plant',
                imageUrl: imageUrl ?? 'assets/images/placeholder_plant.png',
                description:
                    'A beautiful ${name ?? 'plant'} that is ${type?.toLowerCase() ?? 'lovely'} and easy to care for.',
                timeToWater: watering ?? 'Moderate',
                isToxic: isToxic ?? false,
                isIndoor: type == 'Indoor',
                origin: origin ?? 'Unknown',
                history:
                    'This plant has a rich history in ${origin ?? 'various regions'}.',
                fertilizerInfo: 'Apply balanced fertilizer monthly.',
              ),
            ),
          ),
        );
      },
      child: Container(
        height: cardHeight,
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.0),
          image: DecorationImage(
            image: NetworkImage(
              imageUrl ?? 'assets/images/placeholder_plant.png',
            ),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {},
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Gradient Overlay for better visibility
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Glassmorphism Details Box on the Left
            Positioned(
              left: 5,
              top: 5,
              bottom: 5,
              width: MediaQuery.of(context).size.width * 0.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Theme.of(context).cardColor.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name ?? 'Unknown Plant',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          type ?? 'Unknown Type',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).hintColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${water ?? 0}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.wb_sunny,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${light ?? 0}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Arrow Icon (optional, perhaps top right or bottom right?)
            // I'll leave it out for now as the whole card is tappable, or add a small indicator if needed.
            // The previous design had a specific arrow button. Let's add a small glass circle arrow on the right.
            Positioned(
              right: 20,
              bottom: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Theme.of(context).iconTheme.color,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
