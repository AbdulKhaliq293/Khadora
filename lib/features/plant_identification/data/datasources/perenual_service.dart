import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PerenualService {
  static const String _baseUrl = 'https://perenual.com/api';

  Future<int?> searchPlantId(String query) async {
    final apiKey = dotenv.env['PRENUEL_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Perenual API Key not found in .env file');
    }

    final uri = Uri.parse('$_baseUrl/v2/species-list?key=$apiKey&q=$query');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        
        // Handle case where API returns a List (as reported by user) or Map
        Map<String, dynamic> data;
        if (decoded is List) {
          if (decoded.isEmpty) return null;
          data = decoded.first as Map<String, dynamic>;
        } else if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else {
          return null;
        }

        final List<dynamic>? dataList = data['data'];
        
        if (dataList != null && dataList.isNotEmpty) {
          // Return the ID of the first match
          return dataList[0]['id'];
        }
        return null;
      } else {
        print('Failed to search plant: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error connecting to Perenual API: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPlantDetails(int id) async {
    final apiKey = dotenv.env['PRENUEL_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Perenual API Key not found in .env file');
    }

    final uri = Uri.parse('$_baseUrl/v2/species/details/$id?key=$apiKey');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to get plant details: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error connecting to Perenual API: $e');
      return null;
    }
  }
  
  Future<String?> getCareGuideDescription(String careGuideUrl) async {
     try {
      final response = await http.get(Uri.parse(careGuideUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> dataList = data['data'];
        
        if (dataList.isNotEmpty) {
           // Combine descriptions from sections if available
           // The structure is data -> [0] -> section -> list of sections
           final firstEntry = dataList[0];
           if (firstEntry['section'] != null) {
             final List<dynamic> sections = firstEntry['section'];
             final buffer = StringBuffer();
             
             for (var section in sections) {
               final type = section['type'];
               final description = section['description'];
               buffer.writeln('${type.toString().toUpperCase()}: $description\n');
             }
             return buffer.toString();
           }
        }
        return null;
      } else {
        print('Failed to get care guides: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error connecting to Perenual Care Guide API: $e');
      return null;
    }
  }
}
