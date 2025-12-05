import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:plant_care_app/core/theme/colors.dart'; // Import colors
import 'package:plant_care_app/core/theme/theme_provider.dart'; // Import ThemeProvider
import 'package:plant_care_app/features/auth/data/repositories/auth_repository.dart';
import 'package:plant_care_app/features/auth/presentation/screens/login_screen.dart';
import 'package:plant_care_app/features/plant_collection/domain/entities/plant_model.dart';
import 'package:plant_care_app/features/plant_collection/presentation/providers/plant_collection_provider.dart';
import 'package:plant_care_app/features/plant_collection/presentation/screens/plant_collection_detail_screen.dart';
import 'package:plant_care_app/features/plant_identification/presentation/providers/plant_action_provider.dart';
import 'package:plant_care_app/features/plant_identification/presentation/screens/add_plant_screen.dart'; // Import AddPlantScreen
import 'package:plant_care_app/features/home/data/services/recommendation_service.dart';
import 'package:plant_care_app/features/home/presentation/widgets/recommendation_card.dart';
import 'package:plant_care_app/features/home/presentation/screens/recommendation_list_screen.dart';
import 'package:plant_care_app/features/weather/presentation/widgets/forecast_widget.dart';
import 'package:plant_care_app/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:plant_care_app/core/services/notification_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  // Change to ConsumerStatefulWidget
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState(); // Change to ConsumerState
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Change to ConsumerState
  String _selectedCategory = 'All'; // State for selected category
  String _searchQuery = ''; // State for search query

  @override
  void initState() {
    super.initState();
    // Request notification permissions on home screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).requestPermissions();
    });
  }

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final user = ref.watch(authRepositoryProvider).currentUser;
        final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User Info
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: user?.photoURL != null
                      ? NetworkImage(user!.photoURL!)
                      : null,
                  child: user?.photoURL == null ? const Icon(Icons.person) : null,
                ),
                title: Text(user?.displayName ?? 'User'),
                subtitle: Text(user?.email ?? 'No email'),
              ),
              const Divider(),
              // Theme Setting
              ListTile(
                leading: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme(value);
                    Navigator.pop(context); // Close modal after changing theme
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              ),
              // Notification Settings
              ListTile(
                leading: Icon(Icons.notifications, color: Theme.of(context).primaryColor),
                title: const Text('Notifications'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context); // Close modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationSettingsScreen(),
                    ),
                  );
                },
              ),
              // Logout
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log Out', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context); // Close modal
                  await ref.read(authRepositoryProvider).signOut();
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final plantsAsync = ref.watch(plantCollectionProvider);
    final recommendationsAsync = ref.watch(recommendationsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Logo/Name and Profile
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_florist,
                        color: Theme.of(context).primaryColor,
                        size: 40,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Khodra',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.headlineLarge?.color,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _showProfileModal,
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      backgroundImage: ref.watch(authRepositoryProvider).currentUser?.photoURL != null
                          ? NetworkImage(ref.watch(authRepositoryProvider).currentUser!.photoURL!)
                          : null,
                      child: ref.watch(authRepositoryProvider).currentUser?.photoURL == null
                          ? Icon(Icons.person, color: Theme.of(context).primaryColor)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const ForecastWidget(),
              const SizedBox(height: 24),

              // Search Bar
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
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

              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // Recommendations Section
                    SliverToBoxAdapter(
                      child: recommendationsAsync.when(
                        data: (plants) => plants.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Top Recommendations',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.arrow_forward,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const RecommendationListScreen(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 300,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: plants.length > 3 ? 3 : plants.length,
                                      itemBuilder: (context, index) {
                                        return RecommendationCard(plant: plants[index]);
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              )
                            : const SizedBox.shrink(),
                        loading: () => const SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
                        error: (error, stack) => const SizedBox.shrink(),
                      ),
                    ),

                    // Category Filters
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ),
                    ),

                    // Plant List
                    plantsAsync.when(
                      data: (plants) {
                        final filteredPlants = plants.where((plant) {
                          final matchesCategory = _selectedCategory == 'All' ||
                              plant.category == _selectedCategory;
                          final matchesSearch = plant.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());
                          return matchesCategory && matchesSearch;
                        }).toList();

                        if (filteredPlants.isEmpty) {
                          return SliverToBoxAdapter(
                            child: Center(
                              child: Text(
                                'No plants found in this category.',
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                          );
                        }

                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final plant = filteredPlants[index];
                              return _buildPlantCard(context, plant);
                            },
                            childCount: filteredPlants.length,
                          ),
                        );
                      },
                      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
                      error: (error, stack) => SliverToBoxAdapter(
                        child: Center(
                          child: Text(
                            'Error loading plants: $error',
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                      ),
                    ),
                  ],
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Plant plant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete ${plant.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(plantActionProvider).deletePlant(plant.plantId, plant.imageUrl);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Plant deleted')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting plant: $e')),
          );
        }
      }
    }
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

  Widget _buildPlantCard(BuildContext context, Plant plant) {
    final cardHeight = MediaQuery.of(context).size.height * 0.28;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PlantCollectionDetailScreen(plant: plant),
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
              plant.imageUrl.isNotEmpty
                  ? plant.imageUrl
                  : 'https://images.unsplash.com/photo-1588302740742-1accfa27b0f6?auto=format&fit=crop&q=60&w=900', // Fallback
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
                          plant.name,
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
                          plant.category,
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
                              plant.timeToWater,
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
            // Arrow Icon
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
            // Delete Button
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _confirmDelete(context, ref, plant),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 20,
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
