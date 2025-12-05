import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:plant_care_app/core/theme/colors.dart';
import 'package:plant_care_app/features/plant_collection/data/services/gemini_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:plant_care_app/features/plant_collection/domain/entities/maintenance_log.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plant_care_app/features/plant_collection/domain/entities/plant_model.dart';
import 'package:plant_care_app/features/plant_collection/presentation/providers/maintenance_provider.dart';
import 'package:plant_care_app/features/weather/data/services/weather_service.dart';
import 'package:plant_care_app/features/weather/presentation/providers/weather_provider.dart';
import 'package:plant_care_app/features/plant_identification/presentation/providers/plant_action_provider.dart';
import 'package:plant_care_app/features/plant_collection/presentation/providers/plant_collection_provider.dart';

class PlantCollectionDetailScreen extends ConsumerStatefulWidget {
  final Plant plant;

  const PlantCollectionDetailScreen({super.key, required this.plant});

  @override
  ConsumerState<PlantCollectionDetailScreen> createState() =>
      _PlantCollectionDetailScreenState();
}

class _PlantCollectionDetailScreenState
    extends ConsumerState<PlantCollectionDetailScreen> {
  bool _isLoadingAdvice = false;

  void _showNotifications() {
    final plantsAsync = ref.read(plantCollectionProvider);
    final Plant plant = plantsAsync.value?.firstWhere(
      (p) => p.plantId == widget.plant.plantId,
      orElse: () => widget.plant,
    ) ?? widget.plant;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NotificationSheet(plant: plant),
    );
  }

  void _showMaintenanceDetails(MaintenanceType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    type == MaintenanceType.water ? "Watering History" : "Fertilizer History",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () => _showAddLogDialog(type),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final logsAsync = ref.watch(maintenanceLogsProvider(widget.plant.plantId));
                    
                    return logsAsync.when(
                      data: (logs) {
                        final typeLogs = logs.where((l) => l.type == type).toList();
                        
                        if (typeLogs.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  type == MaintenanceType.water ? Icons.water_drop_outlined : Icons.eco_outlined,
                                  size: 64,
                                  color: Theme.of(context).hintColor.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No logs yet",
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 16,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => _showAddLogDialog(type),
                                  child: const Text("Add your first log"),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView(
                          controller: scrollController,
                          children: [
                            // Graph
                            SizedBox(
                              height: 200,
                              child: _MaintenanceGraph(logs: typeLogs, type: type),
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              "Recent Logs",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // List of logs
                            ...typeLogs.map((log) => ListTile(
                              leading: CircleAvatar(
                                backgroundColor: (type == MaintenanceType.water ? Colors.blue : Colors.green).withOpacity(0.1),
                                child: Icon(
                                  type == MaintenanceType.water ? Icons.water_drop : Icons.eco,
                                  color: type == MaintenanceType.water ? Colors.blue : Colors.green,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                DateFormat('MMM d, yyyy').format(log.date),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('h:mm a').format(log.date),
                                    style: TextStyle(color: Theme.of(context).hintColor),
                                  ),
                                  if (log.note != null && log.note!.isNotEmpty)
                                    Text(
                                      log.note!,
                                      style: TextStyle(
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                    ),
                                ],
                              ),
                              isThreeLine: log.note != null && log.note!.isNotEmpty,
                              trailing: Text(
                                "${log.amount.toStringAsFixed(0)} ${type == MaintenanceType.water ? 'ml' : 'g'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            )),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAddLogDialog(MaintenanceType type) async {
    double amount = type == MaintenanceType.water ? 200.0 : 10.0; // Default values
    final noteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: Text(
              'Log ${type == MaintenanceType.water ? 'Water' : 'Fertilizer'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Amount: ${amount.toInt()} ${type == MaintenanceType.water ? 'ml' : 'g'}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: type == MaintenanceType.water ? Colors.blue : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: type == MaintenanceType.water ? Colors.blue : Colors.green,
                      inactiveTrackColor: (type == MaintenanceType.water ? Colors.blue : Colors.green).withOpacity(0.2),
                      thumbColor: type == MaintenanceType.water ? Colors.blue : Colors.green,
                      overlayColor: (type == MaintenanceType.water ? Colors.blue : Colors.green).withOpacity(0.2),
                      valueIndicatorColor: type == MaintenanceType.water ? Colors.blue : Colors.green,
                    ),
                    child: Slider(
                      value: amount,
                      min: 0,
                      max: type == MaintenanceType.water ? 1000.0 : 100.0,
                      divisions: type == MaintenanceType.water ? 20 : 20,
                      label: amount.round().toString(),
                      onChanged: (value) {
                        setState(() {
                          amount = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('0', style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          type == MaintenanceType.water ? '1000ml' : '100g',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (type == MaintenanceType.fertilizer) ...[
                    const SizedBox(height: 24),
                    TextField(
                      controller: noteController,
                      decoration: InputDecoration(
                        labelText: 'Fertilizer Name',
                        hintText: 'e.g. NPK 20-20-20',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: type == MaintenanceType.water ? Colors.blue : Colors.green,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await ref.read(maintenanceActionProvider).addLog(
                        widget.plant.plantId,
                        type,
                        amount,
                        note: noteController.text.isNotEmpty ? noteController.text : null,
                      );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${type == MaintenanceType.water ? 'Water' : 'Fertilizer'} log added')),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showGeminiAdvice() async {
    setState(() {
      _isLoadingAdvice = true;
    });

    try {
      final logs = await ref.read(maintenanceLogsProvider(widget.plant.plantId).future);
      
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _GeminiChatSheet(
          plant: widget.plant,
          recentLogs: logs,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open chat: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAdvice = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final plantsAsync = ref.watch(plantCollectionProvider);
    
    final Plant plant = plantsAsync.value?.firstWhere(
      (p) => p.plantId == widget.plant.plantId,
      orElse: () => widget.plant,
    ) ?? widget.plant;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image (Full Screen)
          Positioned.fill(
            child: Image.network(
              plant.imageUrl,
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
                  onTap: _showNotifications,
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
                          plant.name,
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                height: 1.1,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          plant.isIndoor
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
                              plant.timeToWater,
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

                        const SizedBox(height: 24),

                        // Gemini AI Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor.withOpacity(0.8),
                                Theme.of(context).primaryColor,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isLoadingAdvice ? null : _showGeminiAdvice,
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 20,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_isLoadingAdvice)
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    else ...[
                                      const Icon(
                                        Icons.auto_awesome,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        "Ask AI for Care Guide",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Maintenance Section
                        _buildSectionHeader("Maintenance"),
                        const SizedBox(height: 16),
                        _buildMaintenanceCard(
                          context: context,
                          title: "Watering",
                          subtitle: "Tap to view history",
                          icon: Icons.water_drop,
                          color: Colors.blue,
                          onTap: () => _showMaintenanceDetails(MaintenanceType.water),
                        ),
                        const SizedBox(height: 12),
                        // Always show fertilizer option, if info is null show generic subtitle
                        _buildMaintenanceCard(
                          context: context,
                          title: "Fertilizer",
                          subtitle: plant.fertilizerInfo ?? "Tap to view history",
                          icon: Icons.eco,
                          color: Colors.green,
                          onTap: () => _showMaintenanceDetails(MaintenanceType.fertilizer),
                        ),

                        const SizedBox(height: 32),

                        // Details Section
                        _buildSectionHeader("About"),
                        const SizedBox(height: 12),
                        Text(
                          plant.description,
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
                          plant.origin,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          Icons.history,
                          "History",
                          plant.history,
                        ),

                        const SizedBox(height: 32),
                        
                        // Detailed Attributes Section
                        _buildSectionHeader("Plant Details"),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (plant.type != null) _buildAttributeChip("Type", plant.type!),
                            if (plant.cycle != null) _buildAttributeChip("Cycle", plant.cycle!),
                            if (plant.growthRate != null) _buildAttributeChip("Growth", plant.growthRate!),
                            if (plant.hardiness != null) _buildAttributeChip("Hardiness", plant.hardiness!),
                            if (plant.poisonousToHumans == true) _buildAttributeChip("Poisonous (Humans)", "Yes", color: Colors.red),
                            if (plant.poisonousToPets == true) _buildAttributeChip("Poisonous (Pets)", "Yes", color: Colors.red),
                            if (plant.droughtTolerant == true) _buildAttributeChip("Drought Tolerant", "Yes", color: Colors.green),
                            if (plant.invasive == true) _buildAttributeChip("Invasive", "Yes", color: Colors.orange),
                          ],
                        ),

                        if (plant.careInstructions != null) ...[
                          const SizedBox(height: 32),
                          _buildSectionHeader("Care Instructions"),
                          const SizedBox(height: 12),
                          Text(
                            plant.careInstructions!,
                            style: const TextStyle(
                              color: Colors.black87,
                              height: 1.6,
                              fontSize: 15,
                            ),
                          ),
                        ],
                        
                        if (plant.pruning != null) ...[
                          const SizedBox(height: 32),
                          _buildSectionHeader("Pruning"),
                          const SizedBox(height: 12),
                           _buildInfoRow(
                            Icons.cut,
                            "Best time to prune",
                            plant.pruning!,
                          ),
                        ],
                        
                        if (plant.sunlight != null) ...[
                          const SizedBox(height: 32),
                          _buildSectionHeader("Sunlight"),
                          const SizedBox(height: 12),
                           _buildInfoRow(
                            Icons.wb_sunny,
                            "Requirement",
                            plant.sunlight!,
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
    final weatherAsync = ref.watch(weatherProvider);

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
      child: weatherAsync.when(
        data: (weather) => Column(
          children: [
            const SizedBox(height: 6),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getWeatherIcon(weather.iconCode),
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
                        "${weather.temperature.round()}°C",
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
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (err, stack) => Center(
          child: Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  IconData _getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d': return Icons.wb_sunny;
      case '01n': return Icons.nightlight_round;
      case '02d':
      case '02n': return Icons.wb_cloudy;
      case '03d':
      case '03n':
      case '04d':
      case '04n': return Icons.cloud;
      case '09d':
      case '09n': return Icons.grain;
      case '10d':
      case '10n': return Icons.water_drop;
      case '11d':
      case '11n': return Icons.flash_on;
      case '13d':
      case '13n': return Icons.ac_unit;
      case '50d':
      case '50n': return Icons.blur_on;
      default: return Icons.wb_sunny;
    }
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

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

class _GeminiChatSheet extends ConsumerStatefulWidget {
  final Plant plant;
  final List<MaintenanceLog> recentLogs;

  const _GeminiChatSheet({
    required this.plant,
    required this.recentLogs,
  });

  @override
  ConsumerState<_GeminiChatSheet> createState() => _GeminiChatSheetState();
}

class _GeminiChatSheetState extends ConsumerState<_GeminiChatSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = true;
  // Note: We should strictly use Google Generative AI types here, but passing it around might be complex.
  // Ideally GeminiService returns an opaque handle or we keep it here.
  // Since GeminiService provides startChat, we'll use it.
  late final dynamic _chatSession; 

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'plant_advice_${widget.plant.plantId}';
      final timeKey = 'plant_advice_time_${widget.plant.plantId}';
      
      final cachedAdvice = prefs.getString(cacheKey);
      final cachedTimeStr = prefs.getString(timeKey);
      
      String? adviceToUse;
      bool useCache = false;

      if (cachedAdvice != null && cachedTimeStr != null) {
        final cachedTime = DateTime.parse(cachedTimeStr);
        if (DateTime.now().difference(cachedTime).inHours < 24) {
          useCache = true;
          adviceToUse = cachedAdvice;
        }
      }

      final service = ref.read(geminiServiceProvider);
      _chatSession = service.startPlantChat(
        plantName: widget.plant.name,
        description: widget.plant.description,
        isIndoor: widget.plant.isIndoor,
        recentLogs: widget.recentLogs,
        cachedAdvice: useCache ? adviceToUse : null,
      );

      if (useCache && adviceToUse != null) {
        if (mounted) {
          setState(() {
            _messages.add(_ChatMessage(text: adviceToUse!, isUser: false));
            _isLoading = false;
          });
        }
      } else {
        final initialAdvice = await service.getInitialCareAdvice(_chatSession);
        
        await prefs.setString(cacheKey, initialAdvice);
        await prefs.setString(timeKey, DateTime.now().toIso8601String());

        if (mounted) {
          setState(() {
            _messages.add(_ChatMessage(text: initialAdvice, isUser: false));
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: "Error initializing chat: $e", isUser: false));
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Import 'package:google_generative_ai/google_generative_ai.dart'; is needed for Content.text
      // Since we can't easily change imports in this file block without affecting top, 
      // we'll assume we can call sendMessage on _chatSession directly if we type it correctly or use dynamic.
      // _chatSession is of type ChatSession.
      final response = await _chatSession.sendMessage(Content.text(text));
      
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(
            text: response.text ?? "I couldn't generate a response.",
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: "Error: $e", isUser: false));
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    "Plant Care Assistant",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // Chat List
            Expanded(
              child: _messages.isEmpty && _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController, // Use local controller for auto-scroll
                      // Note: Using DraggableScrollableSheet's controller allows the sheet to drag, 
                      // but we want auto-scroll. Nested scrolling might be tricky. 
                      // A common pattern is to let the sheet be full height mostly.
                      // We'll try to attach the primary controller if we want drag, but for chat, local control is better for 'scrollToBottom'.
                      // However, if we don't use 'scrollController' passed by sheet, it won't drag up/down by scrolling content.
                      // Let's try just using Expanded and our own list view.
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_isLoading && _messages.isNotEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          );
                        }
                        final msg = _messages[index];
                        return Align(
                          alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(12),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                            decoration: BoxDecoration(
                              color: msg.isUser 
                                  ? Theme.of(context).primaryColor 
                                  : Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16).copyWith(
                                bottomRight: msg.isUser ? const Radius.circular(0) : null,
                                bottomLeft: !msg.isUser ? const Radius.circular(0) : null,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: msg.isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Input Area
            Padding(
              padding: EdgeInsets.fromLTRB(
                16, 
                8, 
                16, 
                MediaQuery.of(context).viewInsets.bottom + 16 // Handle keyboard
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Ask a follow-up question...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSheet extends ConsumerWidget {
  final Plant plant;

  const _NotificationSheet({required this.plant});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(maintenanceLogsProvider(plant.plantId));

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.8,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).hintColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              "Notifications",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            
            // Upcoming
            Text(
              "Upcoming",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            _buildUpcomingTile(
              context,
              "Watering",
              plant.nextWaterDate,
              Icons.water_drop,
              Colors.blue,
            ),
            const SizedBox(height: 8),
            _buildUpcomingTile(
              context,
              "Fertilizing",
              plant.nextFertilizeDate,
              Icons.eco,
              Colors.green,
            ),

            const SizedBox(height: 24),

            // History (Previous)
            Text(
              "History",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 12),
            
            Expanded(
              child: logsAsync.when(
                data: (logs) {
                  if (logs.isEmpty) {
                    return Center(
                      child: Text(
                        "No history yet",
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    );
                  }
                  // Sort logs by date descending
                  final sortedLogs = List<MaintenanceLog>.from(logs)
                    ..sort((a, b) => b.date.compareTo(a.date));

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: sortedLogs.length,
                    itemBuilder: (context, index) {
                      final log = sortedLogs[index];
                      final isWater = log.type == MaintenanceType.water;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: (isWater ? Colors.blue : Colors.green).withOpacity(0.1),
                          child: Icon(
                            isWater ? Icons.water_drop : Icons.eco,
                            color: isWater ? Colors.blue : Colors.green,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          isWater ? "Watered" : "Fertilized",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          DateFormat('MMM d, h:mm a').format(log.date),
                          style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
                        ),
                        trailing: log.note != null && log.note!.isNotEmpty
                            ? const Icon(Icons.note, size: 16, color: Colors.grey)
                            : null,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await ref.read(plantActionProvider).scheduleBulkNotifications(plant, 4);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications scheduled for next 4 months')),
                      );
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.schedule, color: Colors.white),
                label: const Text(
                  "Schedule Next 4 Months",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTile(
    BuildContext context, 
    String title, 
    DateTime? date, 
    IconData icon, 
    Color color
  ) {
    if (date == null) return const SizedBox.shrink();

    final now = DateTime.now();
    // Reset times for correct day comparison
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(date.year, date.month, date.day);
    final diff = dueDay.difference(today).inDays;

    String dueText;
    Color dueColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    if (diff < 0) {
      dueText = "Overdue by ${diff.abs()} days";
      dueColor = Colors.red;
    } else if (diff == 0) {
      dueText = "Today";
      dueColor = Colors.orange;
    } else if (diff == 1) {
      dueText = "Tomorrow";
    } else {
      dueText = "In $diff days (${DateFormat('MMM d').format(date)})";
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                dueText,
                style: TextStyle(color: dueColor, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MaintenanceGraph extends StatelessWidget {
  final List<MaintenanceLog> logs;
  final MaintenanceType type;

  const _MaintenanceGraph({
    required this.logs,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    // Filter logs for the last 30 days
    final now = DateTime.now();
    final recentLogs = logs.where((log) {
      return log.date.isAfter(now.subtract(const Duration(days: 30)));
    }).toList();
    
    // Sort by date
    recentLogs.sort((a, b) => a.date.compareTo(b.date));

    if (recentLogs.isEmpty) {
      return const Center(child: Text("No data for the last 30 days"));
    }

    final color = type == MaintenanceType.water ? Colors.blue : Colors.green;

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < recentLogs.length) {
                  // Show date for every 5th item or first/last to avoid overcrowding
                  if (index == 0 || index == recentLogs.length - 1 || index % 5 == 0) {
                    final date = recentLogs[index].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('MM/dd').format(date),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: recentLogs.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.amount);
            }).toList(),
            isCurved: true,
            color: color,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
