// lib/pages/outfit_recommendations_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/outfit.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';

class OutfitRecommendationsPage extends StatefulWidget {
  const OutfitRecommendationsPage({super.key});

  @override
  _OutfitRecommendationsPageState createState() =>
      _OutfitRecommendationsPageState();
}

class _OutfitRecommendationsPageState extends State<OutfitRecommendationsPage> {
  final ImagePicker _picker = ImagePicker();

  // Loading state
  bool _isLoading = false;

  // Raw uploaded URLs (for debugging or further logic)
  List<String> _uploadedImageUrls = [];

  // Recommended outfit suggestions
  List<Outfit> _outfits = [];

  // (Optional) You can expose this via a dropdown later
  String _selectedCategory = 'All';

  /// Pick one or more images from gallery, upload them,
  /// then fetch outfit recommendations.
  Future<void> _pickAndFetch() async {
    final List<XFile>? pics = await _picker.pickMultiImage();
    if (pics == null || pics.isEmpty) return;

    setState(() {
      _isLoading = true;
      _uploadedImageUrls = [];
      _outfits = [];
    });

    try {
      // Upload and collect download URLs
      final List<String> urls = await StorageService.uploadWardrobe(pics);
      setState(() => _uploadedImageUrls = urls);

      // Fetch outfit recommendations from your AI backend
      final List<Outfit> recs = await AiService.getOutfits(
        imageUrls: urls,
        category: _selectedCategory,
      );

      setState(() => _outfits = recs);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recommendations: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outfit Recommendations')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Upload button
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick & Upload Photos'),
              onPressed: _isLoading ? null : _pickAndFetch,
            ),

            const SizedBox(height: 16),

            // Loading spinner
            if (_isLoading) const Center(child: CircularProgressIndicator()),

            // Recommendations grid
            if (!_isLoading && _outfits.isNotEmpty)
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _outfits.length,
                  itemBuilder: (context, i) {
                    final outfit = _outfits[i];
                    return Card(
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // show the first image of this suggested outfit
                          if (outfit.imageUrls.isNotEmpty)
                            Expanded(
                              child: Image.network(
                                outfit.imageUrls.first,
                                fit: BoxFit.cover,
                              ),
                            ),

                          // show the outfit title
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              outfit.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

            // Placeholder hint when nothing yet
            if (!_isLoading && _outfits.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'Upload one or more photos to see outfit suggestions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
