import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherModel {
  final double temperature;
  final String condition;
  final String iconCode;
  final String cityName;

  WeatherModel({
    required this.temperature,
    required this.condition,
    required this.iconCode,
    required this.cityName,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
      cityName: json['name'],
    );
  }
}

class ForecastDayModel {
  final DateTime date;
  final double temperature;
  final String condition;
  final String iconCode;

  ForecastDayModel({
    required this.date,
    required this.temperature,
    required this.condition,
    required this.iconCode,
  });

  factory ForecastDayModel.fromJson(Map<String, dynamic> json) {
    return ForecastDayModel(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      condition: json['weather'][0]['main'],
      iconCode: json['weather'][0]['icon'],
    );
  }
}

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<WeatherModel> fetchCurrentWeather() async {
    final apiKey = dotenv.env['OPEN_WEATHER_API_KEY'];
    if (apiKey == null) {
      throw Exception('OPEN_WEATHER_API_KEY not found in .env');
    }

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition();

    // Call API
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data: ${response.statusCode}');
    }
  }

  Future<List<ForecastDayModel>> fetchForecast() async {
    final apiKey = dotenv.env['OPEN_WEATHER_API_KEY'];
    if (apiKey == null) {
      throw Exception('OPEN_WEATHER_API_KEY not found in .env');
    }

    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current position
    final position = await Geolocator.getCurrentPosition();

    // Call API (5 Day / 3 Hour Forecast)
    final response = await http.get(
      Uri.parse(
        '$_baseUrl/forecast?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final list = data['list'] as List;
      
      // Filter to get one item per day (e.g., around noon)
      // The list gives data every 3 hours. We can group by day.
      final Map<String, ForecastDayModel> dailyForecasts = {};
      
      for (var item in list) {
        final dt = DateTime.fromMillisecondsSinceEpoch(item['dt'] * 1000);
        final dateKey = "${dt.year}-${dt.month}-${dt.day}";
        
        // If we haven't added this day yet, or if this item is closer to noon (12:00)
        if (!dailyForecasts.containsKey(dateKey)) {
           dailyForecasts[dateKey] = ForecastDayModel.fromJson(item);
        } else {
           // Update if this one is closer to 12:00 PM
           final currentStored = dailyForecasts[dateKey]!;
           if ((dt.hour - 12).abs() < (currentStored.date.hour - 12).abs()) {
             dailyForecasts[dateKey] = ForecastDayModel.fromJson(item);
           }
        }
      }

      return dailyForecasts.values.take(7).toList();
    } else {
      throw Exception('Failed to load forecast data: ${response.statusCode}');
    }
  }
}
