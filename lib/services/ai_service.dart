
// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/outfit.dart';

class AiService {
  // This is where my  AI magic happens - think of it as our fashion consultant's address
  static const _endpoint = 'https://api-4gybzjk4wq-uc.a.run.app/getOutfits';

  /// This is our main function that asks the AI: "Hey, what should I wear?"
  /// We give it some photos and tell it what kind of occasion we're dressing for,
  /// and it comes back with awesome outfit suggestions!
  static Future<List<Outfit>> getOutfits({
    required List<String> imageUrls,
    required String category,
  }) async {
    //  sending our request to the AI
    final resp = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'images': imageUrls, 'category': category}),
    );

    //  this helps us debug if things go wrong
    print('-- AI RESPONSE STATUS: ${resp.statusCode}');
    print('-- AI RESPONSE BODY: ${resp.body}');

    // shows if Something went wrong with our request
    if (resp.statusCode != 200) {
      throw Exception('AI error ${resp.statusCode}: ${resp.body}');
    }

    //  unwraps the AI's response like opening a present
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    
    // The AI gave us a list of outfit recommendations - let's grab them
    final recs = data['recommendations'] as List<dynamic>;
    
    // Transform each recommendation into a proper Outfit object we can work with
    // It's like translating the AI's language into something our app understands
    return recs.map((e) => Outfit.fromJson(e as Map<String, dynamic>)).toList();
  }
}
