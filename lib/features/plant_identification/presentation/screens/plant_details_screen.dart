import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_care_app/core/theme/colors.dart';
import 'package:plant_care_app/features/plant_identification/presentation/providers/plant_action_provider.dart';

class PlantDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> plant; // Expecting a map with plant details

  const PlantDetailsScreen({super.key, required this.plant});

  @override
  ConsumerState<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends ConsumerState<PlantDetailsScreen> {
  bool _isSaving = false;

  Future<void> _addToCollection() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await ref.read(plantActionProvider).addToCollection(widget.plant);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Plant added to collection!')),
        );
        // Navigate to Home Screen or Collection Screen?
        // User said: "second add to collection which add over firebase"
        // Usually after adding, we might go back home or to collection.
        // I'll pop to root (Home) as per "cancel which take to the home screen".
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding plant: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                borderRadius: BorderRadius.circular(0.0),
                child: widget.plant['imageFile'] != null && widget.plant['imageFile'] is File
                    ? Image.file(
                        widget.plant['imageFile'] as File,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 300,
                      )
                    : Image.network(
                        widget.plant['imageUrl'] ?? 'assets/images/placeholder_plant.png',
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.plant['name'] ?? 'Unknown Plant',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  if (widget.plant['scientificName'] != null && widget.plant['scientificName'].isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.plant['scientificName'],
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).hintColor,
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    widget.plant['type'] ?? 'Unknown Family',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (widget.plant['confidence'] != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Match: ${(widget.plant['confidence'] * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                   if (widget.plant['commonNames'] != null && (widget.plant['commonNames'] as List).isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Common Names',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      (widget.plant['commonNames'] as List).join(', '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _addToCollection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add to Collection',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).hintColor.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
