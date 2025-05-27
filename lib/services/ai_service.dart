// lib/services/ai_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/outfit.dart';

class AiService {
  // Point to your mock endpoint
  static const _endpoint = 'https://api-4gybzjk4wq-uc.a.run.app/getOutfits';

  /// Calls your /getOutfits endpoint and maps the JSON into Outfit models.
  static Future<List<Outfit>> getOutfits({
    required List<String> imageUrls,
    required String category,
  }) async {
    final resp = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'images': imageUrls, 'category': category}),
    );

    print('-- AI RESPONSE STATUS: ${resp.statusCode}');
    print('-- AI RESPONSE BODY: ${resp.body}');

    if (resp.statusCode != 200) {
      throw Exception('AI error ${resp.statusCode}: ${resp.body}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final recs = data['recommendations'] as List<dynamic>;
    return recs.map((e) => Outfit.fromJson(e as Map<String, dynamic>)).toList();
  }
}
