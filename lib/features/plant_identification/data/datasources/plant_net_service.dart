import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plant_care_app/features/plant_identification/data/models/plant_identification_model.dart';

class PlantNetService {
  static const String _baseUrl = 'https://my-api.plantnet.org/v2/identify/all';

  Future<PlantIdentificationModel> identifyPlant(File imageFile) async {
    final apiKey = dotenv.env['PLANT_NET_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('PlantNet API Key not found in .env file');
    }

    final uri = Uri.parse('$_baseUrl?api-key=$apiKey');

    var request = http.MultipartRequest('POST', uri);
    
    // Add the image file
    request.files.add(await http.MultipartFile.fromPath('images', imageFile.path));
    
    // Optional parameters can be added here (e.g. organs=auto)
    // request.fields['organs'] = 'auto'; 

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return PlantIdentificationModel.fromJson(json);
      } else {
        throw Exception('Failed to identify plant: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to PlantNet API: $e');
    }
  }
}
