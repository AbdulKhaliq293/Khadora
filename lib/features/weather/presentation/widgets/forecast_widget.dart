import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:plant_care_app/features/weather/data/services/weather_service.dart';
import 'package:plant_care_app/features/weather/presentation/providers/weather_provider.dart';

class ForecastWidget extends ConsumerWidget {
  const ForecastWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forecastAsync = ref.watch(forecastProvider);
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.textTheme.bodyLarge?.color;

    return forecastAsync.when(
      data: (forecast) {
        if (forecast.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 100,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: forecast.map((day) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 70,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.2),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryColor.withOpacity(0.2),
                              primaryColor.withOpacity(0.05),
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(day.date),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Icon(
                              _getWeatherIcon(day.iconCode),
                              color: Colors.orange,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${day.temperature.round()}°C',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
            const SizedBox(width: 8),
            const Expanded(child: Text("Could not load weather")),
          ],
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
}
