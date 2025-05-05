// lib/ai_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'outfit.dart';

class AiService {
  // no leading space here!
  static const _endpoint = 
    'https://us-central1-closetly-e3486.cloudfunctions.net/getOutfits';

  /// Sends a list of image URLs (or file paths) plus [category]
  /// and returns the AI’s Outfit suggestions.
  static Future<List<Outfit>> getOutfits({
    required List<String> imageUrls,
    String category = 'All',
  }) async {
    final resp = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'images': imageUrls,
        'category': category,
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('AI service error: ${resp.statusCode} ${resp.body}');
    }

    final List data = jsonDecode(resp.body) as List;
    return data.map((o) => Outfit.fromJson(o)).toList();
  }
}
