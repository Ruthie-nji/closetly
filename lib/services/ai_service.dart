// lib/services/ai_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// A simple model for an AI-recommended outfit.
class Outfit {
  final String imageUrl;
  final String description;

  Outfit({required this.imageUrl, required this.description});

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String,
    );
  }
}

class AiService {
  static const _endpoint = 'https://your-ai-endpoint.com/get-outfits';
  static const _apiKey = 'YOUR_API_KEY_HERE';

  static Future<List<Outfit>> getOutfits({
    required List<String> imageUrls,
    required String category,
  }) async {
    final resp = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        if (_apiKey.isNotEmpty) 'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({'imageUrls': imageUrls, 'category': category}),
    );

    if (resp.statusCode != 200) {
      throw Exception('AI error: ${resp.statusCode} ${resp.body}');
    }

    final data = jsonDecode(resp.body) as List<dynamic>;
    return data.map((e) => Outfit.fromJson(e as Map<String, dynamic>)).toList();
  }
}
