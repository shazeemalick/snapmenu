import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:easy_menu/models/menu_item.dart';

class GeminiService {
  // TODO: Securely manage API Key (e.g., via .env or sensitive config)
  static const String _apiKey = "gemini_api_key_here"; 
  
  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: _apiKey,
        );

  Future<List<MenuItem>> extractMenu(Uint8List imageBytes) async {
    try {
      final prompt = [
        Content.multi([
          TextPart("""
            Analyze this menu image and extract all menu items. 
            For each item, identify:
            1. Name
            2. Category (e.g., Beverages, Mains, Desserts, Starters)
            3. Price (The base price or price for single size)
            4. Description (optional, if available)
            5. Variations (If an item has multiple sizes like Small, Medium, Large, extract each size and its corresponding price)

            Return the data STRICTLY as a JSON array of objects with the keys: 
            "name" (string), 
            "category" (string), 
            "price" (number), 
            "description" (string or null),
            "variations" (null or array of objects with keys "size" and "price")

            Ensure all price values are numbers. 
            Do not include any other text or markdown formatting in your response.
          """),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await _model.generateContent(prompt);
      final text = response.text;

      if (text == null) return [];

      // Clean the response from potential markdown backticks
      final cleanedText = text.replaceAll('```json', '').replaceAll('```', '').trim();
      
      final List<dynamic> jsonData = jsonDecode(cleanedText);
      return jsonData.map((item) => MenuItem.fromJson(item)).toList();
    } catch (e) {
      print("Gemini Extraction Error: $e");
      return [];
    }
  }
}
