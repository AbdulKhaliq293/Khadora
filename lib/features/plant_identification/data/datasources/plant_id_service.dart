import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PlantIdService {
  static const String _baseUrl = 'https://plant.id/api/v3/kb/plants';

  Future<String?> searchPlantId(String query) async {
    final apiKey = dotenv.env['PLANT_ID_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      // If the key is missing, we just return null and fall back to other services
      print('Plant.id API Key not found in .env file');
      return null;
    }

    final uri = Uri.parse('$_baseUrl/name_search?q=$query');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Api-Key': apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> entities = data['entities'];
        
        if (entities.isNotEmpty) {
          // Return the access_token (entity_id) of the first match
          return entities[0]['access_token'];
        }
        return null;
      } else {
        print('Failed to search plant in Plant.id: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error connecting to Plant.id API: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPlantDetails(String accessToken) async {
    final apiKey = dotenv.env['PLANT_ID_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return null;
    }

    // Request all useful details
    final details = [
      'common_names',
      'description',
      'watering',
      'best_watering',
      'best_light_condition',
      'best_soil_type',
      'toxicity',
      'propagation_methods',
      'edible_parts',
      'cultural_significance'
    ].join(',');

    final uri = Uri.parse('$_baseUrl/$accessToken?details=$details&language=en');

    try {
      final response = await http.get(
        uri,
        headers: {
          'Api-Key': apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to get plant details from Plant.id: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error connecting to Plant.id API: $e');
      return null;
    }
  }
}
