// lib/outfit.dart

/// Simple data model for an AI outfit suggestion.
class Outfit {
  final String title;
  final List<String> imageUrls;

  Outfit({
    required this.title,
    required this.imageUrls,
  });

  factory Outfit.fromJson(Map<String, dynamic> json) {
    return Outfit(
      title: json['title'] as String,
      imageUrls: List<String>.from(json['images'] as List),
    );
  }
}

