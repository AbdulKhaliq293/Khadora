import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_care_app/features/home/data/services/recommendation_service.dart';
import 'package:plant_care_app/features/home/presentation/widgets/recommendation_card.dart';

class RecommendationListScreen extends ConsumerWidget {
  const RecommendationListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Recommendations'),
      ),
      body: SafeArea(
        child: recommendationsAsync.when(
          data: (plants) => plants.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: plants.length,
                itemBuilder: (context, index) {
                  // Use a container to give it some height/width context if needed, 
                  // or assume RecommendationCard works in vertical list.
                  // Based on home_screen, RecommendationCard is used in a horizontal list with fixed height 300.
                  // Let's check RecommendationCard implementation if possible, or just try using it.
                  // Usually horizontal cards have fixed width. In a vertical list, we might want full width.
                  // For now, let's just use it and wrap in a Center or SizedBox if it looks weird.
                  // Actually, if RecommendationCard is designed for horizontal scroll, it might have a specific width.
                  // Let's assume it's adaptable or I'll wrap it.
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      height: 300, 
                      child: RecommendationCard(plant: plants[index])
                    ),
                  );
                },
              )
              : const Center(child: Text('No recommendations found')),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
