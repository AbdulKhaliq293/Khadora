import 'package:flutter/material.dart';
import 'package:plant_care_app/core/theme/colors.dart'; // Import colors

class PlantDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> plant; // Expecting a map with plant details

  const PlantDetailsScreen({super.key, required this.plant});

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        title: Text(
          'Plant Details',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 4, // Number of tabs
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ClipRRect(
                    borderRadius: BorderRadius.circular(0.0), // No border radius for the image in SliverAppBar
                    child: Image.network(
                      widget.plant['imageUrl'] ?? 'assets/images/placeholder_plant.png', // Fallback image
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 300,
                        color: Theme.of(context).hintColor.withOpacity(0.3),
                        child: Icon(Icons.broken_image, color: Theme.of(context).hintColor, size: 50),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 24.0), // Adjusted top padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.plant['name'] ?? 'Unknown Plant',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.plant['type'] ?? 'Unknown Type',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: Theme.of(context).textTheme.bodyLarge?.color,
                    unselectedLabelColor: Theme.of(context).hintColor,
                    indicatorColor: Theme.of(context).primaryColor,
                    tabs: const [
                      Tab(text: 'History'),
                      Tab(text: 'Water Task'),
                      Tab(text: 'Health Task'),
                      Tab(text: 'Health History'),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              // History Tab Content
              _buildTabContent(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(context, 'Origin', widget.plant['origin'] ?? 'Unknown'),
                    _buildDetailSection(context, 'Watering Frequency', widget.plant['watering'] ?? 'Unknown'),
                    _buildDetailSection(context, 'Maintenance Notes', widget.plant['maintenance'] ?? 'Unknown'),
                    _buildDetailSection(context, 'Care Level', widget.plant['care_level'] ?? 'Unknown'),
                  ],
                ),
              ),
              // Water Task Tab Content
              _buildTabContent(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusIndicator(context, Icons.water_drop, 'Water Level', '${widget.plant['water'] ?? 0}%', Theme.of(context).primaryColor),
                    const SizedBox(height: 24),
                    _buildDetailSection(context, 'Watering Schedule', widget.plant['watering'] ?? 'Check plant type for details'),
                    _buildDetailSection(context, 'Next Watering', 'TBD'),
                  ],
                ),
              ),
              // Health Task Tab Content (Sunlight)
              _buildTabContent(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusIndicator(context, Icons.sunny, 'Light Exposure', '${widget.plant['light'] ?? 0}%', Theme.of(context).primaryColor),
                    const SizedBox(height: 24),
                    _buildDetailSection(context, 'Sunlight Requirements', widget.plant['sunlight'] ?? 'Prefers bright, indirect light'),
                    _buildManagementItem(context, Icons.eco, 'Fertilizer Info', widget.plant['fertilizerInfo'] ?? 'No specific info'),
                    _buildManagementItem(context, Icons.favorite, 'Current Health', widget.plant['healthStatus'] ?? 'Good'),
                  ],
                ),
              ),
              // Health History Tab Content
              _buildTabContent(
                context,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection(context, 'Toxic to Humans', widget.plant['isToxic'] ?? false ? 'Yes' : 'No'),
                    const SizedBox(height: 16),
                    _buildManagementItem(context, Icons.history, 'Health Check History', widget.plant['healthCheckHistory']?.join(', ') ?? 'No history'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Example: go back
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt, color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve(MaterialState.values.toSet())), // Camera icon
              const SizedBox(width: 10),
              Text(
                'Scan Again',
                style: TextStyle(fontSize: 18, color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve(MaterialState.values.toSet()), fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for tab content with box-like visual hierarchy
  Widget _buildTabContent(BuildContext context, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), // Increased horizontal padding
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Use theme card color
          borderRadius: BorderRadius.circular(16.0), // Increased radius for softer corners
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.3), // Softer shadow
              spreadRadius: 1,
              blurRadius: 8, // Increased blur for softer shadow
              offset: const Offset(0, 4), // Increased offset for more depth
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0), // Increased padding inside boxes
        child: child,
      ),
    );
  }

  // Helper widget for status indicators
  Widget _buildStatusIndicator(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 18.0), // Increased padding
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Use theme card color
        borderRadius: BorderRadius.circular(12.0), // Increased radius
        border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.2)), // Even more subtle border
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        children: [
          Icon(icon, color: iconColor, size: 32), // Slightly larger icon
          const SizedBox(height: 10), // Increased spacing
          Text(
            label,
            style: TextStyle(fontSize: 15, color: Theme.of(context).hintColor), // Slightly larger font
          ),
          const SizedBox(height: 5), // Increased spacing
          Text(
            value,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color), // Slightly larger font
          ),
        ],
      ),
    );
  }

  // Helper widget for detail sections within tabs
  Widget _buildDetailSection(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Increased vertical padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18, // Slightly larger for detail sections
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.95), // Slightly less white
            ),
          ),
          const SizedBox(height: 5), // Increased spacing
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8)), // Slightly larger and less opaque
          ),
          Divider(color: Theme.of(context).hintColor.withOpacity(0.1), height: 20), // Even more subtle divider
        ],
      ),
    );
  }

  // Helper widget for management items within tabs
  Widget _buildManagementItem(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // Increased vertical padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 26), // Slightly larger icon
              const SizedBox(width: 14), // Increased spacing
              Text(
                label,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.95)), // Slightly larger and less white
              ),
            ],
          ),
          const SizedBox(height: 5), // Spacing between label and value
          Padding(
            padding: const EdgeInsets.only(left: 40.0), // Indent value to align with icon
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8)), // Slightly larger and less opaque
              overflow: TextOverflow.ellipsis, // Handle long text
            ),
          ),
          Divider(color: Theme.of(context).hintColor.withOpacity(0.1), height: 20), // Even more subtle divider
        ],
      ),
    );
  }
}

// Delegate for SliverPersistentHeader to host the TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minHeight => _tabBar.preferredSize.height;
  @override
  double get maxHeight => _tabBar.preferredSize.height;

  // Add missing getters for maxExtent and minExtent
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Ensure background is black
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
