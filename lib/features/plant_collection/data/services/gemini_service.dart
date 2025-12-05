import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:plant_care_app/features/plant_collection/domain/entities/maintenance_log.dart';

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

  ChatSession startPlantChat({
    required String plantName,
    required String description,
    required bool isIndoor,
    List<MaintenanceLog> recentLogs = const [],
    String? cachedAdvice,
  }) {
    String historyContext = "";
    if (recentLogs.isNotEmpty) {
      // Filter for last 10 logs
      final sortedLogs = List<MaintenanceLog>.from(recentLogs)
        ..sort((a, b) => b.date.compareTo(a.date));
      final last10 = sortedLogs.take(10).toList();

      historyContext = "\n\nHere is the recent care history for this plant:\n";
      for (var log in last10) {
        final dateStr = DateFormat('yyyy-MM-dd').format(log.date);
        final typeStr = log.type == MaintenanceType.water ? 'Watered' : 'Fertilized';
        final noteStr = log.note != null && log.note!.isNotEmpty ? " (${log.note})" : "";
        historyContext += "- $dateStr: $typeStr ${log.amount.toInt()}${log.type == MaintenanceType.water ? 'ml' : 'g'}$noteStr\n";
      }
      historyContext += "\nPlease take this history into account when giving advice. If you notice any issues with the frequency or amounts, please mention it.";
    }

    final systemPrompt = '''
You are a plant care expert. I have a plant named "$plantName".
It is an ${isIndoor ? 'indoor' : 'outdoor'} plant.
Description: $description
$historyContext

You are here to answer questions strictly related to this plant's care, maintenance, and health. 
If the user asks about anything unrelated to plants or gardening, politely refuse to answer and steer the conversation back to the plant.

Keep the tone helpful, encouraging, and easy to understand.
''';

    final history = [
      Content.text(systemPrompt),
      Content.model([TextPart("Understood. I am ready to help with $plantName.")]),
    ];

    if (cachedAdvice != null) {
      // Inject the cached advice into the history so the model knows it "said" it.
      // We also need a user prompt that triggered it to keep the conversation logical.
      history.add(Content.text("Please provide a comprehensive care guide for this plant."));
      history.add(Content.model([TextPart(cachedAdvice)]));
    }

    return _model.startChat(history: history);
  }

  Future<String> getInitialCareAdvice(ChatSession chat) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return 'Please add your Gemini API Key to the .env file.';
    }

    const prompt = '''
Please provide a comprehensive care guide for this plant. 
The response should be in plain text (not markdown) or simple markdown that looks good in a mobile app dialog.
Include the following sections:
1. 🛡️ Safety Guidelines: Is it toxic? How to keep it safe?
2. 💧 Watering Schedule: When and how often to water? Signs of over/under watering.
3. 💊 Fertilization: When and what type of fertilizer to use?
4. 🌡️ Ideal Environment: Light, temperature, and humidity needs.
5. 💡 Pro Tips: Any special secrets for this plant?
''';

    try {
      final response = await chat.sendMessage(Content.text(prompt));
      return response.text ?? 'Unable to generate advice at this time.';
    } catch (e) {
      return 'Error generating advice: $e';
    }
  }

  Future<Map<String, dynamic>> getPlantCareDetails({
    required String plantName,
    required String description,
    required bool isIndoor,
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return {};
    }

    // Prompt for structured JSON
    final prompt = '''
I have a plant named "$plantName".
It is an ${isIndoor ? 'indoor' : 'outdoor'} plant.
Description: $description

Please provide the following care details in strict JSON format.
Do NOT include any markdown formatting (like ```json ... ```). Just return the raw JSON string.

{
  "water_frequency_days": (int) recommended days between watering,
  "fertilizer_frequency_days": (int) recommended days between fertilizing,
  "fertilizer_type": (string) recommended fertilizer type (short),
  "short_care_summary": (string) a concise (1-2 sentences) summary of when to water and what fertilizer to use. This will be sent as a notification to the user immediately.
}
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text == null) return {};

      // Clean up potential markdown code blocks just in case
      final cleanText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      
      try {
        final jsonMap = json.decode(cleanText);
        return jsonMap as Map<String, dynamic>;
      } catch (e) {
        print("Error parsing JSON from Gemini: $e");
        return {};
      }
    } catch (e) {
      print("Error generating care details: $e");
      return {};
    }
  }
}
