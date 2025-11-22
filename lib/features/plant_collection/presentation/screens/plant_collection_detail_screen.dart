import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:plant_care_app/core/theme/colors.dart';
import 'package:plant_care_app/features/plant_collection/domain/entities/plant_model.dart';

class PlantCollectionDetailScreen extends StatefulWidget {
  final Plant plant;

  const PlantCollectionDetailScreen({super.key, required this.plant});

  @override
  State<PlantCollectionDetailScreen> createState() =>
      _PlantCollectionDetailScreenState();
}

class _PlantCollectionDetailScreenState
    extends State<PlantCollectionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image (Full Screen)
          Positioned.fill(
            child: Image.network(
              widget.plant.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
            ),
          ),

          // 2. Gradient Overlay for better text visibility at the top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).shadowColor,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 3. Top Navigation
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                _buildCircleButton(
                  icon: Icons.notifications_outlined,
                  onTap: () {},
                ),
              ],
            ),
          ),

          // 4. Temperature/Health Slider (Fixed on Right)
          Positioned(
            top: size.height * 0.2,
            right: 20,
            child: _buildVerticalSlider(),
          ),

          // 5. Draggable Glass Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(40),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.75),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).cardColor.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).hintColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Header
                        Text(
                          widget.plant.name,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.plant.isIndoor
                              ? "Indoor Plant"
                              : "Outdoor Plant",
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).hintColor,
                                fontWeight: FontWeight.w500,
                              ),
                        ),

                        const SizedBox(height: 30),

                        // Stats Grid
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatBadge(
                              Icons.water_drop_outlined,
                              "Water",
                              widget.plant.timeToWater,
                            ),
                            _buildStatBadge(
                              Icons.wb_sunny_outlined,
                              "Light",
                              "High",
                            ), // Placeholder
                            _buildStatBadge(
                              Icons.thermostat,
                              "Temp",
                              "18-25°C",
                            ), // Placeholder
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Maintenance Section
                        _buildSectionHeader("Maintenance"),
                        const SizedBox(height: 16),
                        _buildMaintenanceCard(
                          context: context,
                          title: "Watering",
                          subtitle: "Next: Tomorrow",
                          icon: Icons.water_drop,
                          color: Colors.blue,
                          onTap: () {},
                        ),
                        const SizedBox(height: 12),
                        if (widget.plant.fertilizerInfo != null)
                          _buildMaintenanceCard(
                            context: context,
                            title: "Fertilizer",
                            subtitle: widget.plant.fertilizerInfo!,
                            icon: Icons.eco,
                            color: Colors.green,
                            onTap: () {},
                          ),

                        const SizedBox(height: 32),

                        // Details Section
                        _buildSectionHeader("About"),
                        const SizedBox(height: 12),
                        Text(
                          widget.plant.description,
                          style: const TextStyle(
                            color: Colors.black87,
                            height: 1.6,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 24),

                        _buildSectionHeader("Origin & History"),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.public,
                          "Origin",
                          widget.plant.origin,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.history,
                          "History",
                          widget.plant.history,
                        ),

                        const SizedBox(height: 32),
                        
                        // Detailed Attributes Section
                        _buildSectionHeader("Plant Details"),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (widget.plant.type != null) _buildAttributeChip("Type", widget.plant.type!),
                            if (widget.plant.cycle != null) _buildAttributeChip("Cycle", widget.plant.cycle!),
                            if (widget.plant.growthRate != null) _buildAttributeChip("Growth", widget.plant.growthRate!),
                            if (widget.plant.hardiness != null) _buildAttributeChip("Hardiness", widget.plant.hardiness!),
                            if (widget.plant.poisonousToHumans == true) _buildAttributeChip("Poisonous (Humans)", "Yes", color: Colors.red),
                            if (widget.plant.poisonousToPets == true) _buildAttributeChip("Poisonous (Pets)", "Yes", color: Colors.red),
                            if (widget.plant.droughtTolerant == true) _buildAttributeChip("Drought Tolerant", "Yes", color: Colors.green),
                            if (widget.plant.invasive == true) _buildAttributeChip("Invasive", "Yes", color: Colors.orange),
                          ],
                        ),

                        if (widget.plant.careInstructions != null) ...[
                          const SizedBox(height: 32),
                          _buildSectionHeader("Care Instructions"),
                          const SizedBox(height: 12),
                          Text(
                            widget.plant.careInstructions!,
                            style: const TextStyle(
                              color: Colors.black87,
                              height: 1.6,
                              fontSize: 15,
                            ),
                          ),
                        ],
                        
                        if (widget.plant.pruning != null) ...[
                          const SizedBox(height: 32),
                          _buildSectionHeader("Pruning"),
                          const SizedBox(height: 12),
                           _buildInfoRow(
                            Icons.cut,
                            "Best time to prune",
                            widget.plant.pruning!,
                          ),
                        ],
                        
                        if (widget.plant.sunlight != null) ...[
                          const SizedBox(height: 32),
                          _buildSectionHeader("Sunlight"),
                          const SizedBox(height: 12),
                           _buildInfoRow(
                            Icons.wb_sunny,
                            "Requirement",
                            widget.plant.sunlight!,
                          ),
                        ],

                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Theme.of(context).iconTheme.color,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildVerticalSlider() {
    return Container(
      height: 180,
      width: 56,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: Colors.orange,
              size: 24,
            ),
          ),
          Expanded(
            child: Center(
              child: RotatedBox(
                quarterTurns: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "24°C",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 44,
            height: 80,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.orangeAccent, Colors.lightBlueAccent],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 20,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).cardColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Theme.of(context).cardColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, String title, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).cardColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 28,
            color: Theme.of(context).iconTheme.color,
          ),
          const SizedBox(height: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).hintColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 18),
    );
  }

  Widget _buildMaintenanceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).cardColor.withOpacity(0.4),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).shadowColor.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                size: 20,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).hintColor),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: "$title: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: content,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttributeChip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (color ?? Theme.of(context).primaryColor).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
