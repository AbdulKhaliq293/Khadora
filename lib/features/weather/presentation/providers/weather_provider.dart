import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_care_app/features/weather/data/services/weather_service.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

final weatherProvider = FutureProvider<WeatherModel>((ref) async {
  final service = ref.watch(weatherServiceProvider);
  return service.fetchCurrentWeather();
});

final forecastProvider = FutureProvider<List<ForecastDayModel>>((ref) async {
  final service = ref.watch(weatherServiceProvider);
  return service.fetchForecast();
});
