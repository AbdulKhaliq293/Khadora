import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TrefleService {
  static const String _baseUrl = 'https://trefle.io/api/v1';

  Future<int?> searchPlantId(String query) async {
    final apiKey = dotenv.env['TRAFELAR_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Trefle API Key not found in .env file');
    }

    final uri = Uri.parse('$_baseUrl/plants/search?token=$apiKey&q=$query');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> dataList = data['data'];
        
        if (dataList.isNotEmpty) {
          // Return the ID of the first match
          return dataList[0]['id'];
        }
        return null;
      } else {
        print('Failed to search plant in Trefle: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error connecting to Trefle API: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPlantDetails(int id) async {
    final apiKey = dotenv.env['TRAFELAR_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Trefle API Key not found in .env file');
    }

    final uri = Uri.parse('$_baseUrl/plants/$id?token=$apiKey');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to get plant details from Trefle: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error connecting to Trefle API: $e');
      return null;
    }
  }
}
