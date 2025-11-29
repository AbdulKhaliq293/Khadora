import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService();
});

class GeminiService {
  late final GenerativeModel _model;
  final String _apiKey;

  GeminiService() : _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '' {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // Using the latest Flash model available (2.0 Experimental)
      apiKey: _apiKey,
    );
  }

  Future<String> getPlantCareAdvice({
    required String plantName,
    required String description,
    required bool isIndoor,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return 'Please add your Gemini API Key to the .env file.';
    }

    final prompt = '''
You are a plant care expert. I have a plant named "$plantName".
It is an ${isIndoor ? 'indoor' : 'outdoor'} plant.
Description: $description

Please provide a comprehensive care guide for this plant. 
The response should be in plain text (not markdown) or simple markdown that looks good in a mobile app dialog.
Include the following sections:
1. 🛡️ Safety Guidelines: Is it toxic? How to keep it safe?
2. 💧 Watering Schedule: When and how often to water? Signs of over/under watering.
3. 💊 Fertilization: When and what type of fertilizer to use?
4. 🌡️ Ideal Environment: Light, temperature, and humidity needs.
5. 💡 Pro Tips: Any special secrets for this plant?

Keep the tone helpful, encouraging, and easy to understand.
''';

    final content = [Content.text(prompt)];
    
    try {
      final response = await _model.generateContent(content);
      return response.text ?? 'Unable to generate advice at this time.';
    } catch (e) {
      return 'Error generating advice: $e';
    }
  }
}
